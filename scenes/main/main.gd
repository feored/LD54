extends Node2D

const turnIndicatorPrefab = preload("res://ui/turn_indicator/turn_indicator.tscn")
const escMenuPrefab = preload("res://ui/esc_menu/esc_menu.tscn")
const gameOverScreenPrefab = preload("res://ui/game_over_menu/game_over_screen.tscn")
const shapePrefab = preload("res://world/tiles/highlight/shape.tscn")

@onready var world = $"World"
@onready var turnContainer = $"%TurnContainer"
@onready var turnLabel = $"%TurnLabel"
@onready var messenger = $"%Message"
@onready var endTurnButton = $"%TurnButton"
@onready var sacrificeButton = $"%SacrificeButton"
@onready var sacrificeLabel = $"%SacrificeLabel"
@onready var fastForwardButton = $"%FastForwardButton"

const player_team_index: int = 0

var sacrifice_item : Shape = null
var sacrifices_available : int = 0
var eliminated_teams : Array[int] = []

var selected_region = null
var teams : Array[int] = []
var turn : int = 0

var global_turn = 0

var actions_history : Array[Action] = []
var bots : Dictionary = {}

var turn_indicators : Array[Node] = []

var game_started : bool = false
var escMenu : Node = null

var spectating : bool = false




# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.input_locked = false
	self.world.init(Callable(self.messenger, "set_message"))
	Music.play_track(Music.Track.World)
	Sfx.enable_track(Sfx.Track.Boom)
	self.load_map()
	self.add_teams()
	self.start_game()
	self.world.camera.move_instant(self.world.map_to_local(closest_player_tile_coords()))

func update_sacrifices_display():
	self.sacrificeLabel.set_text(str(sacrifices_available))


func add_teams():
	self.bots.clear()
	for t in self.turn_indicators:
		t.queue_free()
	self.turn_indicators.clear()
	for team_id in teams:
		self.bots[team_id] = DumbBot.new(team_id)
		self.create_turn_indicator(team_id)


func start_game():
	self.game_started = true
	for r in self.world.regions.values():
		r.units = 0
	for t in self.teams:
		generate_units(t)


func create_turn_indicator(team_id):
	var turnIndicator = turnIndicatorPrefab.instantiate()
	turnIndicator.init(Color.hex(Constants.TEAM_COLORS[team_id]), false if team_id > 1 else true)
	turnContainer.add_child(turnIndicator)
	self.turn_indicators.append(turnIndicator)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func clear_sacrifice():
	self.sacrifice_item.queue_free()
	self.sacrifice_item = null

func sacrifice_tiles(coords):
	var sink_action = Action.new(self.teams[self.player_team_index], Constants.Action.Sacrifice, 0, 0, coords )
	actions_history.append(sink_action)
	self.apply_action(sink_action)


func handle_sacrificing(event):
	if event is InputEventMouseMotion:
		var tile_hovered = world.global_pos_to_coords(event.position)
		self.sacrifice_item.try_place(tile_hovered, self.world.tiles.keys())
		self.sacrifice_item.position = self.world.map_to_local(tile_hovered)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var tile_hovered = world.global_pos_to_coords(event.position)
		if self.sacrifice_item.placeable(tile_hovered, self.world.tiles.keys()):
			sacrifice_tiles(self.sacrifice_item.adjusted_shape_coords(tile_hovered))
			self.sacrifices_available -= self.sacrifice_item.shape.size()
			self.update_sacrifices_display()
			self.clear_sacrifice()
		else:
			messenger.set_message("You must acquire more favor from Neptune first, my lord.")
			clear_sacrifice()

func _unhandled_input(event):
	if event.is_action_pressed("escmenu"):
		if escMenu == null:
			escMenu = escMenuPrefab.instantiate()
			self.add_child(escMenu)
		else:
			escMenu.delete()
	if event.is_action_pressed("skip"):
		fast_forward(true)
	elif event.is_action_released("skip"):
		fast_forward(false)
	else:
		if Settings.input_locked or !game_started:
			return
		## Right click to cancel
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				clear_selected_region()
				clear_sacrifice()
		elif event is InputEventMouse:
			if self.sacrifice_item != null:
				handle_sacrificing(event)
			else:
				var coords_clicked = world.global_pos_to_coords(event.position)
				if world.tiles.has(coords_clicked):
					if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
						on_tile_clicked(world.tiles[coords_clicked])


func _on_turn_button_pressed():
	self.endTurnButton.disabled = true
	self.sacrificeButton.disabled = true
	clear_selected_region()
	self.world.clear_regions_used()
	Settings.input_locked = true

	await play_global_turn()

	Settings.input_locked = false
	self.endTurnButton.disabled = false
	self.sacrificeButton.disabled = false

	var tile_camera_move = closest_player_tile_coords()
	if tile_camera_move != Constants.NULL_COORDS:
		await self.world.camera.move_smoothed(self.world.map_to_local(tile_camera_move), 5)
	

func closest_player_tile_coords():
	var closest_player_tile = Constants.NULL_COORDS
	var closest_tile_distance = 100000
	var camera_tile = self.world.local_to_map(self.world.camera.position)
	for region in self.world.regions:
		if self.world.regions[region].team == self.teams[self.player_team_index]:
			var center_tile = self.world.regions[region].center_tile()
			var distance = Utils.distance(center_tile, camera_tile)
			if distance < closest_tile_distance:
				closest_player_tile = center_tile
				closest_tile_distance = distance
	return closest_player_tile
	
	
func check_global_turn_over():
	return self.turn == self.teams.size() - 1

func check_win_condition():
	for team in self.teams:
		if not regions_left(team) and team not in eliminated_teams:
			eliminated_teams.append(team)
			messenger.set_message(Constants.TEAM_NAMES[team] + " has been wiped from the island!")
	var teams_alive = get_teams_alive()
	if self.teams[self.player_team_index] not in teams_alive and teams_alive.size() > 1 and not spectating:
		var game_won = self.teams[self.player_team_index] in teams_alive
		var gameOverScreen = gameOverScreenPrefab.instantiate()
		gameOverScreen.init(game_won, self, true)
		self.add_child(gameOverScreen)
	elif teams_alive.size() < 2:
		var game_won = self.teams[self.player_team_index] in teams_alive
		var gameOverScreen = gameOverScreenPrefab.instantiate()
		gameOverScreen.init(game_won, self, false)
		self.add_child(gameOverScreen)


func check_teams_on_islands(teams_alive):
	var all_teams_on_islands = true
	for region in self.world.regions:
		for neighbor_region in self.world.adjacent_regions(region):
			if world.regions[region].team != world.regions[neighbor_region].team:
				all_teams_on_islands = false
				break
	if all_teams_on_islands:
		var units_per_team = {}
		var winner = teams_alive[0]
		var winning_units = 0
		for team in teams_alive:
			units_per_team[team] = 0
			for region in self.world.regions:
				if self.world.regions[region].team == team:
					units_per_team[team] += self.world.regions[region].units
			if units_per_team[team] > winning_units:
				winner = team
				winning_units = units_per_team[team]

func get_teams_alive():
	var teams_alive = []
	for team in teams:
		if regions_left(team):
			teams_alive.append(team)
	return teams_alive
	

func clear_selected_region():
	if selected_region != null:
		self.world.regions[selected_region].set_selected(false)
		self.selected_region = null
		Sfx.play(Sfx.Track.Cancel)
	

func on_tile_clicked(new_clicked_tile):
	if !(self.turn == self.player_team_index):
		print("not player turn")
		clear_selected_region()
		return
	if new_clicked_tile.region in self.world.regions_used:
		print("region used")
		clear_selected_region()
		return
	if selected_region != null and new_clicked_tile.region == selected_region:
		clear_selected_region()
		return
	if selected_region == null:
		if new_clicked_tile.team == self.teams[self.player_team_index]:
			self.selected_region = new_clicked_tile.region
			self.world.regions[selected_region].set_selected(true)
			Sfx.play(Sfx.Track.Select)
	else:
		if new_clicked_tile.region not in self.world.adjacent_regions(self.selected_region):
			clear_selected_region()
			return
		else:
			if self.world.regions[selected_region].units > 1:
				var move = Action.new(self.teams[self.player_team_index], Constants.Action.Move, selected_region, new_clicked_tile.region )
				actions_history.append(move)
				self.apply_action(move)
			else:
				messenger.set_message("My lord, we cannot leave this region undefended!")
			clear_selected_region()

func update_turn_indicators():
	for i in range(self.teams.size()):
		self.turn_indicators[i].set_active(self.turn == i)

func play_global_turn():
	self.turn += 1
	update_turn_indicators()
	while not self.turn == 0:
		if global_turn > 0:
			generate_units(self.teams[self.turn])
		await play_turn(Utils.to_team_id(self.turn))
		self.turn = (self.turn + 1) % (self.teams.size())
		update_turn_indicators()
	
	self.global_turn += 1
	self.turnLabel.set_text("Turn: " + str(self.global_turn))
	await self.world.sink_marked()
	await self.world.mark_tiles(self.global_turn)
	if global_turn > 0:
		generate_units(self.teams[self.player_team_index])

func play_turn(team_id):
	if team_id in self.eliminated_teams:
		return
	while true:
		var bot_action = self.bots[team_id].play_turn(self.world)
		if bot_action.action == Constants.Action.None:
			break
		await apply_action(bot_action)
		self.actions_history.append(bot_action)
		await Utils.wait(Settings.turn_time)
	self.world.clear_regions_used()
	await Utils.wait(Settings.turn_time)

func regions_left(team):
	for region in world.regions:
		if world.regions[region].team == team:
			return true
	return false

func generate_units(team):
	for region in world.regions:
		if world.regions[region].team == team:
			world.regions[region].generate_units()

func apply_action(action : Action):
	match action.action:
		Constants.Action.Move:
			await self.world.move_units(action.region_from, action.region_to, action.team)
		Constants.Action.Sacrifice:
			await self.world.sink_tiles(action.tiles)
		Constants.Action.None:
			pass
		_:
			print("Unknown action: ", action.action)
	check_win_condition()

func load_map():
	self.world.clear_island()
	self.teams.clear()
	for t in Settings.current_map.teams:
		self.teams.append(int(t)) ## json is parsed as floats
	self.world.load_tiles(Settings.current_map.tiles)
	self.world.load_regions(Settings.current_map.regions)

func _on_sacrifice_button_pressed():
	self.sacrifice_item = shapePrefab.instantiate()
	self.sacrifice_item.init()
	self.world.add_child(sacrifice_item)

func fast_forward(val):
	Settings.skip(val)
	self.world.camera.skip(val)
	self.fastForwardButton.button_pressed = val

func _on_fast_forward_button_toggled(button_pressed:bool):
	fast_forward(button_pressed)

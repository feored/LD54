extends Node2D

const gameOverScreenPrefab = preload("res://ui/game_over_menu/game_over_screen.tscn")
const shapePrefab = preload("res://world/tiles/highlight/shape.tscn")
const coinPrefab = preload("res://world/coin.tscn")
const region_info_prefab = preload("res://ui/region_info/region_info.tscn")

@onready var world = $"World"
@onready var messenger = %Message
@onready var endTurnButton = %TurnButton
@onready var resources = %ResourcesPanel
@onready var fastForwardButton = %FastForwardButton
@onready var region_info = %RegionInfo

enum MouseState {
	None,
	Context,
	Sink,
	Move
}

const player_team_index: int = 0

var mouse_state = MouseState.None

var sink_item : Shape = null
var selected_region = null

var teams : Array[int] = []
var eliminated_teams : Array[int] = []

var turn : int = 0
var global_turn = 0

var actions_history : Array[Action] = []
var bots : Dictionary = {}

var game_started : bool = false
var spectating : bool = false



# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.input_locked = false
	Settings.skipping = false
	self.world.init(Callable(self.messenger, "set_message"))
	Music.play_track(Music.Track.World)
	Sfx.enable_track(Sfx.Track.Boom)
	self.load_map(Settings.current_map.teams, Settings.current_map.regions)
	self.resources.init_shapes(Callable(self, "pick_shape_to_sink"))
	self.add_teams()
	
	self.game_started = true
	self.world.camera.move_instant(self.world.map_to_local(closest_player_tile_coords()))

func add_teams():
	self.bots.clear()
	for team_id in teams:
		if team_id != Constants.PLAYER_ID:
			self.bots[team_id] = TerritoryBot.new(team_id, Personalities.AGGRESSIVE_PERSONALITY)
	self.resources.add_teams(self.teams)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
			

func clear_mouse_state():
	region_info.disappear_instant()
	clear_sinking()
	clear_selected_region()
	self.mouse_state = MouseState.None

func clear_sinking():
	if self.sink_item != null:
		self.sink_item.queue_free()
	self.sink_item = null
	for shape_box in self.resources.shape_boxes:
		shape_box.picked = false

func sacrifice_tiles(coords):
	var sink_action = Action.new(self.teams[self.player_team_index], Constants.Action.Sacrifice, 0, 0, coords )
	actions_history.append(sink_action)
	self.apply_action(sink_action)


func handle_sinking(event):
	if event is InputEventMouseMotion:
		var tile_hovered = world.global_pos_to_coords(event.position)
		self.sink_item.try_place(tile_hovered, self.world.tiles.keys())
		self.sink_item.position = self.world.map_to_local(tile_hovered)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var tile_hovered = world.global_pos_to_coords(event.position)
		if self.sink_item.placeable(tile_hovered, self.world.tiles.keys()):
			sacrifice_tiles(self.sink_item.adjusted_shape_coords(tile_hovered))
			self.resources.buy_shape(self.sink_item.shape)
			self.clear_mouse_state()
		else:
			messenger.set_message("You cannot sink that which has already sunk, my lord.")
			clear_mouse_state()

func _unhandled_input(event):
	if event.is_action_pressed("skip"):
		fast_forward(true)
	elif event.is_action_released("skip"):
		fast_forward(false)
	else:
		if Settings.input_locked or !game_started:
			return
		## Right click to cancel
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if self.region_info.shown:
				clear_mouse_state()
				return
			clear_mouse_state()
			var mouse_pos = get_local_mouse_position()
			var tile_hovered = self.world.local_to_map(mouse_pos)
			if world.tiles.has(tile_hovered) and world.tiles[tile_hovered].data.team == self.teams[self.player_team_index]:
				world.tiles[tile_hovered].set_selected(true)
				self.region_info.position = world.tiles[tile_hovered].position#mouse_pos# + Vector2(self.region_info.MARGIN, self.region_info.MARGIN)
				var can_sacrifice = self.world.regions[self.world.tiles[tile_hovered].data.region].data.units > 1
				self.region_info.init(tile_hovered, Constants.DEFAULT_BUILDINGS, world.tiles[tile_hovered].data.building, self.resources.player().gold, can_sacrifice)
				self.mouse_state = MouseState.Context
		elif event is InputEventMouse:
			if self.mouse_state == MouseState.Sink:
				handle_sinking(event)
			else:
				var coords_clicked = world.global_pos_to_coords(event.position)
				if world.tiles.has(coords_clicked):
					if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
						if mouse_state != MouseState.Move:
							clear_mouse_state()
						handle_move(self.world.get_tile_region(coords_clicked))

func buy_building(tile_coords, building):
	self.resources.player().add_gold(-Constants.BUILDINGS[building].cost)
	self.world.tiles[tile_coords].set_building(building)

func sacrifice_region(region_id):
	if self.world.regions[region_id].data.team == self.teams[self.player_team_index]:
		self.resources.player().add_faith(self.world.regions[region_id].sacrifice())
	

func lock_controls(val : bool):
	self.endTurnButton.disabled = val
	self.resources.lock_controls(val)
	

func _on_turn_button_pressed():
	check_coins(self.teams[self.player_team_index])
	self.apply_buildings(self.teams[self.player_team_index])
	self.resources.update()
	
	lock_controls(true)
	clear_mouse_state()
	self.world.clear_regions_used()
	Settings.input_locked = true

	await play_global_turn()
	generate_units(self.teams[self.player_team_index])
	Settings.input_locked = false
	lock_controls(false)

	var tile_camera_move = closest_player_tile_coords()
	if tile_camera_move != Constants.NULL_COORDS:
		await self.world.camera.move_smoothed(self.world.map_to_local(tile_camera_move), 5)
	

func closest_player_tile_coords():
	var closest_player_tile = Constants.NULL_COORDS
	var closest_tile_distance = 100000
	var camera_tile = self.world.local_to_map(self.world.camera.position)
	for region in self.world.regions:
		if self.world.regions[region].data.team == self.teams[self.player_team_index]:
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

func get_teams_alive():
	var teams_alive = []
	for team in teams:
		if regions_left(team):
			teams_alive.append(team)
	return teams_alive
	

func apply_buildings(team):
	self.world.tiles.values().filter(func(t): return t.data.team == team and t.data.building != Constants.Building.None).map(func(t): apply_building(t.data.coords, t.data.building))


func apply_building(tile_coords, building):
	var team_id = self.world.tiles[tile_coords].data.team
	match building:
		Constants.Building.Mine:
			if team_id != Constants.NULL_TEAM:
				self.resources.resources[team_id].add_gold(Constants.MINE_GOLD_PER_TURN)
				self.spawn_coin(tile_coords)
		Constants.Building.Temple:
			if team_id != Constants.NULL_TEAM:
				self.resources.resources[team_id].add_faith(Constants.TEMPLE_FAITH_PER_TURN)

func spawn_coin(tile_coords):
	var coin = coinPrefab.instantiate()
	coin.position = self.world.map_to_local(self.world.tiles[tile_coords].data.coords)
	self.world.add_child(coin)
	
func check_coins(team_id):
	for region in self.world.regions.values().filter(func(r): return r.data.team == team_id and not r.data.is_used):
		self.resources.resources[team_id].add_gold(Constants.GOLD_PER_TURN_PER_REGION)
		spawn_coin(region.center_tile())

func clear_selected_region():
	if selected_region != null:
		self.world.regions[selected_region].set_selected(false)
		self.selected_region = null
	
func handle_move(clicked_region):
	mouse_state = MouseState.Move
	if !(self.turn == self.player_team_index):
		clear_mouse_state()
		return
	if clicked_region.data.is_used:
		clear_mouse_state()
		return
	if selected_region != null and clicked_region.data.id == selected_region:
		clear_mouse_state()
		return
	if selected_region == null:
		if clicked_region.data.team == self.teams[self.player_team_index]:
			self.selected_region = clicked_region.data.id
			self.world.regions[selected_region].set_selected(true)
			Sfx.play(Sfx.Track.Select)
	else:
		if clicked_region.data.id not in self.world.adjacent_regions(self.selected_region):
			clear_mouse_state()
			return
		else:
			self.world.regions[selected_region].update()
			clicked_region.update()
			if self.world.regions[selected_region].data.units > 1:
				var move = Action.new(self.teams[self.player_team_index], Constants.Action.Move, selected_region, clicked_region.data.id )
				actions_history.append(move)
				self.apply_action(move)
			else:
				messenger.set_message("My lord, we cannot leave this region undefended!")
			clear_mouse_state()

func play_global_turn():
	self.turn += 1
	world.path_lengths.clear()
	world.path_lengths = world.all_path_lengths()
	while not self.turn == 0:
		self.messenger.set_message(Constants.TEAM_NAMES[self.teams[self.turn]] + " is making their move.")
		generate_units(self.teams[self.turn])
		await play_turn(Utils.to_team_id(self.turn))
		self.turn = (self.turn + 1) % (self.teams.size())
	
	self.global_turn += 1

	await self.world.sink_marked()
	check_win_condition()
	await self.world.mark_tiles(self.global_turn)

func play_turn(team_id):
	if team_id in self.eliminated_teams:
		return
	var playing = true
	while playing:
		var thread = Thread.new()
		thread.start(self.bots[team_id].play_turn.bind(self.world))
		while thread.is_alive():
			print("Thread is alive")
			await Utils.wait(0.1)
		var bot_actions = thread.wait_to_finish()
		for bot_action in bot_actions:
			if bot_action.action == Constants.Action.None:
				playing = false
				break
			await apply_action(bot_action)
			self.actions_history.append(bot_action)
			await Utils.wait(Settings.turn_time)
	check_coins(self.teams[self.turn])
	self.apply_buildings(self.teams[self.turn])
	self.world.clear_regions_used()
	await Utils.wait(Settings.turn_time)

func regions_left(team):
	for region in world.regions:
		if world.regions[region].data.team == team:
			return true
	return false

func generate_units(team):
	for region in world.regions:
		if !is_instance_valid(world.regions[region]):
			Utils.log("Region %s is not valid" % region)
			break
		if world.regions[region].data.team == team:
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
			Utils.log("Unknown action: %s" % action.action)
	check_win_condition()

func load_map(map_teams, map_regions):
	self.world.clear_island()
	self.teams.clear()
	for t in map_teams:
		self.teams.append(int(t)) ## json is parsed as floats
	self.world.load_regions(map_regions)

func pick_shape_to_sink(shape_coords):
	self.clear_mouse_state()
	self.sink_item = shapePrefab.instantiate()
	self.sink_item.init_with_coords(shape_coords)
	self.world.add_child(sink_item)
	self.sink_item.global_position = get_viewport().get_mouse_position()
	self.mouse_state = MouseState.Sink

func fast_forward(val):
	Settings.skip(val)
	self.world.camera.skip(val)
	self.fastForwardButton.button_pressed = val

func _on_fast_forward_button_toggled(button_pressed:bool):
	fast_forward(button_pressed)


func _on_region_info_tile_unselected(coords):
	if self.world.tiles.has(coords):
		self.world.tiles[coords].set_selected(false)


func _on_region_info_tile_sacrificed(coords):
	self.sacrifice_region(self.world.tiles[coords].data.region)
	clear_mouse_state()


func _on_region_info_building_bought(coords, building):
	self.buy_building(coords, building)
	clear_mouse_state()

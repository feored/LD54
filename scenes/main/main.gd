extends Node2D

const gameOverScreenPrefab = preload("res://ui/game_over_menu/game_over_screen.tscn")
const shapePrefab = preload("res://world/tiles/highlight/shape.tscn")
const card_prefab = preload("res://ui/power/power_card.tscn")

@onready var world = $"World"
@onready var messenger = %Message
@onready var endTurnButton = %TurnButton
@onready var fastForwardButton = %FastForwardButton
@onready var card_selector = %CardSelector
@onready var deck = %Deck
@onready var faith_label = %FaithLabel

var used_card = null
enum MouseState {
	None,
	Sink,
	Sacrifice,
	Emerge,
	Build,
	Move
}

const player_team_index: int = 0

var mouse_state = MouseState.None

var mouse_item : Node = null
var selected_region = null

var teams : Array[int] = []
var eliminated_teams : Array[int] = []
var faith: Dictionary = {}
var powers: Dictionary = {}

var turn : int = 0
var global_turn = 0

var actions_history : Array[Action] = []
var bots : Dictionary = {}

var game_started : bool = false
var spectating : bool = false

var cards_to_pick = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.input_locked = false
	Settings.skipping = false
	self.world.init(Callable(self.messenger, "set_message"))
	Music.play_track(Music.Track.World)
	Sfx.enable_track(Sfx.Track.Boom)
	self.card_selector.cards_picked.connect(Callable(self, "_on_cards_selected"))
	self.load_map(Settings.current_map.teams, Settings.current_map.regions)
	self.add_teams()

	pick_cards()
	self.set_faith(self.teams[self.player_team_index], self.world.tiles.values().filter(func(t): return t.data.team == self.teams[self.player_team_index] and t.data.building == Constants.Building.Shrine).size())

		
	# self.card_selector.init(cards, 3)
	
	self.game_started = true
	self.world.camera.move_instant(self.world.map_to_local(closest_player_tile_coords()))

func add_teams():
	self.bots.clear()
	for team_id in teams:
		if team_id != Constants.PLAYER_ID:
			self.bots[team_id] = TerritoryBot.new(team_id, Personalities.AGGRESSIVE_PERSONALITY)
	for team_id in teams:
		self.faith[team_id] = 0
		self.powers[team_id] = []
			

func clear_mouse_state():
	if self.mouse_item != null:
		self.mouse_item.queue_free()
	self.mouse_item = null
	clear_selected_region()
	self.mouse_state = MouseState.None
	if self.used_card != null:
		self.used_card.highlight(false)
		self.used_card = null	

func sink_tiles(coords):
	var action = Action.new(self.teams[self.player_team_index], Action.Type.Sink, 0, 0, coords )
	actions_history.append(action)
	self.apply_action(action)

func emerge_tiles(coords):
	var action = Action.new(self.teams[self.player_team_index], Action.Type.Emerge, 0, 0, coords )
	actions_history.append(action)
	self.apply_action(action)

func handle_tile_card(event):
	if event is InputEventMouseMotion:
		var tile_hovered = world.global_pos_to_coords(event.position)
		if mouse_state == MouseState.Sink:
			self.mouse_item.try_place(tile_hovered, self.world.tiles.keys())
		elif mouse_state == MouseState.Emerge:
			self.mouse_item.try_emerge(tile_hovered, self.world.tiles.keys())
		self.mouse_item.position = self.world.map_to_local(tile_hovered)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var tile_hovered = world.global_pos_to_coords(event.position)
		if self.mouse_state == MouseState.Sink:
			handle_sink(tile_hovered)
		elif self.mouse_state == MouseState.Emerge:
			handle_emerge(tile_hovered)
		else:
			clear_mouse_state()

func handle_emerge(tile_hovered):
	if self.mouse_item.emergeable(tile_hovered, self.world.tiles.keys()):
		emerge_tiles(self.mouse_item.adjusted_shape_coords(tile_hovered))
		if self.used_card != null:
			card_used(self.used_card)
		self.clear_mouse_state()
	else:
		messenger.set_message("You can only raise land from the sea, my lord.")
		clear_mouse_state()

func handle_sink(tile_hovered):
	if self.mouse_item.placeable(tile_hovered, self.world.tiles.keys()):
		sink_tiles(self.mouse_item.adjusted_shape_coords(tile_hovered))
		if self.used_card != null:
			card_used(self.used_card)
		self.clear_mouse_state()
	else:
		messenger.set_message("You cannot sink that which has already sunk, my lord.")
		clear_mouse_state()

func handle_building(event):
	var coords_hovered = world.global_pos_to_coords(event.position)
	var buildable = func(coords):
		return world.tiles.has(coords)\
		and world.tiles[coords].data.team == self.teams[self.player_team_index]\
		and world.tiles[coords].data.building == Constants.Building.None
	if event is InputEventMouseMotion:
		if buildable.call(coords_hovered):
			self.mouse_item.self_modulate = Color(0.5, 1, 0.5)
		else:
			self.mouse_item.self_modulate = Color(1, 0.5, 0.5)
		self.mouse_item.position = self.world.map_to_local(coords_hovered)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !world.tiles.has(coords_hovered):
			messenger.set_message("You can only build on land, my lord.")
			clear_mouse_state()
			return
		if self.world.tiles[coords_hovered].data.team != self.teams[self.player_team_index]:
			messenger.set_message("You cam only build on territory you own, my lord.")
			clear_mouse_state()
			return
		if self.world.tiles[coords_hovered].data.building != Constants.Building.None:
			messenger.set_message("There is already a construction there, my lord.")
			clear_mouse_state()
			return
		var region_built = self.world.tiles[coords_hovered].data.region
		var action = Action.new(self.teams[self.player_team_index], Action.Type.Build, region_built, Constants.NULL_REGION, [coords_hovered], self.used_card.power.get_building())
		actions_history.append(action)
		self.apply_action(action)
		card_used(self.used_card)
		clear_mouse_state()
			

func handle_sacrifice(event):
	var coords_hovered = world.global_pos_to_coords(event.position)
	if event is InputEventMouseMotion:
		if world.tiles.has(coords_hovered) and self.world.tiles[coords_hovered].data.team == self.teams[self.player_team_index]:
			self.mouse_item.self_modulate = Color(0.5, 1, 0.5)
		else:
			self.mouse_item.self_modulate = Color(1, 0.5, 0.5)
		self.mouse_item.position = self.world.map_to_local(coords_hovered)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !world.tiles.has(coords_hovered):
			messenger.set_message("There are no people to sacrifice here, my lord.")
			clear_mouse_state()
			return
		if self.world.tiles[coords_hovered].data.team != self.teams[self.player_team_index]:
			messenger.set_message("You cannot sacrifice the people of a territory you don't own, my lord.")
			clear_mouse_state()
			return
		var region_sacrificed = self.world.tiles[coords_hovered].data.region
		var action = Action.new(self.teams[self.player_team_index], Action.Type.Sacrifice, region_sacrificed)
		actions_history.append(action)
		self.apply_action(action)
		if self.used_card != null:
			card_used(self.used_card)
		clear_mouse_state()
			
		

func _unhandled_input(event):
	if event.is_action_pressed("skip"):
		fast_forward(true)
	elif event.is_action_released("skip"):
		fast_forward(false)
	elif event is InputEventMouse:
		if Settings.input_locked or !game_started:
			return
		## Right click to cancel
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			clear_mouse_state()
		elif event is InputEventMouse:
			match self.mouse_state:
				MouseState.Sink:
					handle_tile_card(event)
					return
				MouseState.Emerge:
					handle_tile_card(event)
					return
				MouseState.Sacrifice:
					handle_sacrifice(event)
					return
				MouseState.Build:
					handle_building(event)
					return
				_:
					pass
		var coords_clicked = world.global_pos_to_coords(event.position)
		if world.tiles.has(coords_clicked):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if mouse_state != MouseState.Move:
					clear_mouse_state()
				handle_move(self.world.get_tile_region(coords_clicked))

func lock_controls(val : bool):
	self.endTurnButton.disabled = val

func _on_turn_button_pressed():
	self.deck.clear()
	self.apply_buildings(self.teams[self.player_team_index])
	
	lock_controls(true)
	clear_mouse_state()
	self.world.clear_regions_used()
	Settings.input_locked = true

	await play_global_turn()
	generate_units(self.teams[self.player_team_index])
	

	var tile_camera_move = closest_player_tile_coords()
	if tile_camera_move != Constants.NULL_COORDS:
		await self.world.camera.move_smoothed(self.world.map_to_local(tile_camera_move), 5)

	pick_cards()
	self.set_faith(self.teams[self.player_team_index], self.world.tiles.values().filter(func(t): return t.data.team == self.teams[self.player_team_index] and t.data.building == Constants.Building.Shrine).size())
	Settings.input_locked = false
	lock_controls(false)

func add_cards(num):
	var cards = generate_cards(num)
	for c in cards:
		c.picked.connect(func(): use_card(c))
		self.deck.add_card(c)
	self.deck.update_faith(self.faith[self.teams[self.player_team_index]])

func pick_cards():
	var cards_to_generate = 3 + self.world.tiles.values().filter(func(t): return t.data.team == self.teams[self.player_team_index] and t.data.building == Constants.Building.Temple).size()
	add_cards(cards_to_generate)

func _on_cards_selected(cards):
	for card in cards:
		card.disconnect_picked()
		card.picked.connect(func(): use_card(card))
		self.deck.add_card(card)
		self.deck.update_faith(self.faith[self.teams[self.player_team_index]])
	Settings.input_locked = false
	lock_controls(false)
	

func use_card(c):
	self.used_card = c
	c.highlight(true)
	match c.power.id:
		Power.Type.Faith:
			self.add_faith(self.teams[self.player_team_index], 1)
			self.card_used(c)
		Power.Type.Sink:
			set_shape(c.power.shape.coords.keys(), MouseState.Sink)
		Power.Type.Emerge:
			set_shape(c.power.shape.coords.keys(), MouseState.Emerge)
		Power.Type.Sacrifice:
			set_sacrifice()
		Power.Type.Barracks:
			set_building(c.power.get_building())
		Power.Type.Temple:
			set_building(c.power.get_building())
		Power.Type.Fort:
			set_building(c.power.get_building())
		Power.Type.Shrine:
			set_building(c.power.get_building())
		Power.Type.Seal:
			set_building(c.power.get_building())
		_:
			Utils.log("Unknown power type: %s, %s" % [c.power.id, c.power.name])
			self.card_used(c)
			
	
func card_used(c):
	self.add_faith(self.teams[self.player_team_index], -c.power.cost)
	self.deck.remove_card(c)
	self.used_card = null

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
	# var team_id = self.world.tiles[tile_coords].data.team
	match building:
		_:
			pass
		# Constants.Building.Temple:
		# 	self.add_faith(team_id, Constants.TEMPLE_FAITH_PER_TURN)


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
				var move = Action.new(self.teams[self.player_team_index], Action.Type.Move, selected_region, clicked_region.data.id )
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
		self.messenger.set_message(Constants.TEAM_NAMES[self.teams[self.turn]] + " is making their move...")
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
			await Utils.wait(0.1)
		var bot_actions = thread.wait_to_finish()
		for bot_action in bot_actions:
			if bot_action.action == Action.Type.None:
				playing = false
				break
			await apply_action(bot_action)
			self.actions_history.append(bot_action)
			await Utils.wait(Settings.turn_time)
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
		Action.Type.Move:
			await self.world.move_units(action.region_from, action.region_to, action.team)
		Action.Type.Sink:
			await self.world.sink_tiles(action.tiles)
		Action.Type.Emerge:
			await self.world.emerge_tiles(action.tiles)
		Action.Type.Sacrifice:
			sacrifice_region(action.region_from, action.team)
		Action.Type.Build:
			self.world.tiles[action.tiles[0]].set_building(action.misc)
		Action.Type.None:
			pass
		_:
			Utils.log("Unknown action: %s" % action)
	check_win_condition()

func set_faith(team_id, amount):
	self.faith[team_id] = amount
	self.deck.update_faith(self.faith[team_id])
	if team_id == self.teams[self.player_team_index]:
		self.faith_label.set_text(str(amount))

func add_faith(team_id, amount):
	self.faith[team_id] += amount
	self.deck.update_faith(self.faith[team_id])
	if team_id == self.teams[self.player_team_index]:
		self.faith_label.set_text(str(self.faith[team_id]))

func load_map(map_teams, map_regions):
	self.world.clear_island()
	self.teams.clear()
	for t in map_teams:
		self.teams.append(int(t)) ## json is parsed as floats
	self.world.load_regions(map_regions)

func set_shape(shape_coords, mode):
	self.mouse_item = shapePrefab.instantiate()
	self.mouse_item.init_with_coords(shape_coords)
	self.world.add_child(mouse_item)
	self.mouse_item.global_position = get_viewport().get_mouse_position()
	self.mouse_state = mode

func set_sacrifice():
	self.mouse_item = Sprite2D.new()
	self.mouse_item.texture = load("res://assets/icons/skull.png")
	self.world.add_child(mouse_item)
	self.mouse_item.global_position = get_viewport().get_mouse_position()
	self.mouse_state = MouseState.Sacrifice

func set_building(building):
	self.mouse_item = Sprite2D.new()
	self.mouse_item.texture = Constants.BUILDINGS[building].texture
	self.world.add_child(mouse_item)
	self.mouse_item.global_position = get_viewport().get_mouse_position()
	self.mouse_state = MouseState.Build

func fast_forward(val):
	Settings.skip(val)
	self.world.camera.skip(val)
	self.fastForwardButton.button_pressed = val

func generate_cards(cards_num = 3):
	var cards = []
	# var cards_to_generate = self.world.tiles.values()\
	# .filter(func(t): return t.data.team == self.teams[self.player_team_index] and t.data.building == Constants.Building.Shrine).size()
	for _i in range(cards_num):
		var power = Power.new(randi() % Power.Type.size(), (randi() % 5) + 1)
		var card = card_prefab.instantiate()
		card.init(power)
		cards.append(card)
	return cards
			
func sacrifice_region(region_id, team_id):
	if self.world.regions[region_id].data.team == team_id:
		# self.add_faith(team_id, self.world.regions[region_id].sacrifice())
		self.world.regions[region_id].sacrifice()
		self.add_cards(2)
		messenger.set_message("%s has sacrificed a region's inhabitants to the gods!" % Constants.TEAM_NAMES[team_id])
	else:
		Utils.log("Trying to sacrifice region %s, but it belongs to team %s" % [region_id, self.world.regions[region_id].data.team])

func _on_fast_forward_button_toggled(button_pressed:bool):
	fast_forward(button_pressed)

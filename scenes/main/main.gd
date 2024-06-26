extends Node2D

const shape_prefab = preload("res://world/tiles/highlight/shape.tscn")
const mod_list_prefab = preload("res://scenes/overworld/mod_view/mod_list.tscn")

@onready var world = $"World"
@onready var messenger = %Message
@onready var endTurnButton = %TurnButton
@onready var fastForwardButton = %FastForwardButton
@onready var deck = %Deck
@onready var faith_label = %FaithLabel
@onready var mods_scroll_container = %ModsScrollContainer

var used_card = null
var current = {
	"building": Constants.Building.None,
	"reinforcements": 0
}

enum MouseState {
	None,
	Sink,
	Sacrifice,
	Reinforce,
	Emerge,
	Build,
	Move
}

var mouse_state = MouseState.None

var mouse_item : Node = null
var selected_region = null

var cards_to_pick = 1

var game : Game

# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.input_locked = false
	Settings.skipping = false
	self.world.init(Callable(self.messenger, "set_message"))
	Music.play_track(Music.Track.World)
	Sfx.enable_track(Sfx.Track.Boom)

	self.game = Game.new(Info.current_map.teams.map(func(t): return int(t)))
	Effects.init(self.game.players, Callable(self, "apply_active"), Callable(self.game, "get_current_player"))
	self.add_mods(Info.current_mods)
	self.load_map(Info.current_map.regions)
	
	var mod_list = mod_list_prefab.instantiate()
	mod_list.init(Info.current_mods)
	self.mods_scroll_container.add_child(mod_list)
	
	self.game.started = true
	self.world.camera.move_instant(self.world.map_to_local(closest_player_tile_coords()))
	self.deck.card_played = Callable(self, "use_card")
	
	prepare_turn()

func add_mod_effect(e):
	var players_to_apply = []
	if e.target == MapMods.Target.Human:
		players_to_apply = [self.game.human]
	elif e.target == MapMods.Target.Enemies:
		players_to_apply = self.game.players.filter(func(p): return p.team != self.game.human.team)
	elif e.target == Constants.Target.All:
		players_to_apply = self.game.players
	for player in players_to_apply:
		var instanced_effect = Effect.new(e.effect)
		Effects.add(instanced_effect, player)

func add_mods(mods):
	for mod_key in mods:
		var mod = MapMods.mods[mod_key]
		for effect in mod.effects:
			add_mod_effect(effect)
		

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
	var action = Action.new(self.game.human.team, Action.Type.Sink, 0, 0, coords )
	self.game.actions_history.append(action)
	self.apply_action(action)

func emerge_tiles(coords):
	var action = Action.new(self.game.human.team, Action.Type.Emerge, 0, 0, coords )
	self.game.actions_history.append(action)
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
	var tiles_to_sink = self.mouse_item.adjusted_shape_coords(tile_hovered).filter(func(t): return self.world.tiles.has(t))
	sink_tiles(tiles_to_sink)
	if self.used_card != null:
		card_used(self.used_card)
	self.clear_mouse_state()


func handle_building(event):
	var coords_hovered = world.global_pos_to_coords(event.position)
	var buildable = func(coords):
		return world.tiles.has(coords)\
		and world.tiles[coords].data.team == self.game.human.team\
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
		if self.world.tiles[coords_hovered].data.team != self.game.human.team:
			messenger.set_message("You cam only build on territory you own, my lord.")
			clear_mouse_state()
			return
		if self.world.tiles[coords_hovered].data.building != Constants.Building.None:
			messenger.set_message("There is already a construction there, my lord.")
			clear_mouse_state()
			return
		var region_built = self.world.tiles[coords_hovered].data.region
		var action = Action.new(self.game.human.team, Action.Type.Build, region_built, Constants.NULL_REGION, [coords_hovered], self.current.building)
		current.building = Constants.Building.None
		self.game.actions_history.append(action)
		self.apply_action(action)
		card_used(self.used_card)
		clear_mouse_state()
	

func handle_plus(event):
	var coords_hovered = world.global_pos_to_coords(event.position)
	if event is InputEventMouseMotion:
		if world.tiles.has(coords_hovered):
			if self.world.tiles[coords_hovered].data.team == self.game.human.team or (
				self.world.tiles[coords_hovered].data.team == Constants.NULL_TEAM and self.game.human.compute("reinforce_neutral") != 0):
				self.mouse_item.self_modulate = Color(0.5, 1, 0.5)
			else:
				self.mouse_item.self_modulate = Color(1, 0.5, 0.5)
		else:
			self.mouse_item.self_modulate = Color(1, 0.5, 0.5)
		self.mouse_item.position = self.world.map_to_local(coords_hovered)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !world.tiles.has(coords_hovered):
			messenger.set_message("You can't send reinforcements to the sea, my lord.")
			clear_mouse_state()
			return
		if self.world.tiles[coords_hovered].data.team != self.game.human.team:
			if self.world.tiles[coords_hovered].data.team == Constants.NULL_TEAM:
				if self.game.human.compute("reinforce_neutral") == 0:
					messenger.set_message("You cannot send reinforcements to a neutral region!")
					clear_mouse_state()
					return
			else:
				messenger.set_message("You cannot send reinforcements to the enemy!")
				clear_mouse_state()
				return
		var region_reinforced = self.world.tiles[coords_hovered].data.region
		var action = Action.new(self.game.human.team, Action.Type.Reinforce, region_reinforced, 0, [], self.current.reinforcements)
		self.game.actions_history.append(action)
		self.apply_action(action)
		if self.used_card != null:
			card_used(self.used_card)
		clear_mouse_state()

func handle_sacrifice(event):
	var coords_hovered = world.global_pos_to_coords(event.position)
	if event is InputEventMouseMotion:
		if world.tiles.has(coords_hovered) and self.world.tiles[coords_hovered].data.team == self.game.human.team:
			self.mouse_item.self_modulate = Color(0.5, 1, 0.5)
		else:
			self.mouse_item.self_modulate = Color(1, 0.5, 0.5)
		self.mouse_item.position = self.world.map_to_local(coords_hovered)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !world.tiles.has(coords_hovered):
			messenger.set_message("There are no people to sacrifice here, my lord.")
			clear_mouse_state()
			return
		if self.world.tiles[coords_hovered].data.team != self.game.human.team:
			messenger.set_message("You cannot sacrifice the people of a territory you don't own, my lord.")
			clear_mouse_state()
			return
		var region_sacrificed = self.world.tiles[coords_hovered].data.region
		var action = Action.new(self.game.human.team, Action.Type.Sacrifice, region_sacrificed)
		self.game.actions_history.append(action)
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
		if Settings.input_locked or !self.game.started:
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
				MouseState.Reinforce:
					handle_plus(event)
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
	await self.deck.discard_all()
	self.apply_buildings(self.game.human.team)
	
	lock_controls(true)
	clear_mouse_state()
	self.world.clear_regions_used()
	Settings.input_locked = true

	await play_global_turn()
	
	

	var tile_camera_move = closest_player_tile_coords()
	if tile_camera_move != Constants.NULL_COORDS:
		await self.world.camera.move_smoothed(self.world.map_to_local(tile_camera_move), 5)

	## Faith generation
	self.prepare_turn()
	Settings.input_locked = false
	lock_controls(false)

func _on_cards_selected(cards):
	for card in cards:
		card.disconnect_picked()
		card.picked.connect(func(): use_card(card))
		self.deck.add_card(card)
		self.deck.update_faith(self.game.human.resources.faith)
	Settings.input_locked = false
	lock_controls(false)

func active_random_discard(effect):
	await self.deck.discard_random(effect.value)

func active_draw(effect):
	await self.deck.draw_multiple(effect.value)

func active_faith(effect):
	var expression = Expression.new()
	expression.parse(effect.value, self.game.current_player.resources.keys())
	var result = expression.execute(self.game.current_player.resources.values())
	self.game.current_player.resources.faith = result
	if !self.game.current_player.is_bot:
		update_faith_player()

func active_sink_random_self_tiles(effect):
	var own_tiles = self.world.tiles.values().filter(func(t): return t.data.team == self.game.current_player.team)
	var nb = min(effect.value, own_tiles.size())
	var selected = []
	own_tiles.shuffle()
	for i in range(nb):
		selected.push_back(own_tiles.pop_front().data.coords)
	self.sink_tiles(selected)

func active_sink_random_tiles(effect):
	var all_tiles = self.world.tiles.values()
	var nb = min(effect.value, all_tiles.size())
	var selected = []
	all_tiles.shuffle()
	for i in range(nb):
		selected.push_back(all_tiles.pop_front().data.coords)
	self.sink_tiles(selected)

func active_emerge_random_tiles(effect):
	var computed_nb = effect.value + self.game.current_player.compute("flat_emerge_bonus")
	var all_tiles = self.world.tiles.values()
	var empty = []
	for tile in all_tiles:
		for coords in Utils.get_surrounding_cells(tile.data.coords):
			if !self.world.tiles.has(coords):
				empty.push_back(coords)
	var nb = min(computed_nb, all_tiles.size())
	empty.shuffle()
	for i in range(nb):
		self.emerge_tiles([empty.pop_front()])
	
func active_treason(effect):
	var nb_treason = effect.value
	var own_regions = self.world.regions.values().filter(func(r): return r.data.team == self.game.current_player.team)
	own_regions.shuffle()
	for i in range(nb_treason):
		var region = own_regions.pop_front()
		var new_team = self.game.get_random_enemy().team
		region.set_team(new_team)
		region.update()
	messenger.set_message("Regions of %s have defected to the enemy!" % Constants.TEAM_NAMES[self.game.current_player.team])


func active_renewal(effect):
	var own_regions = self.world.regions.values().filter(func(r): return r.data.team == self.game.current_player.team)
	for region in own_regions:
		region.set_used(false)
		region.update()
	

func apply_active(effect):
	var func_name = "active_" + effect.name
	var active_func = Callable(self, func_name)
	if not active_func.is_valid():
		Utils.log("Effect %s is not a valid active effect" % effect.name)
	Callable(self, func_name).call(effect) 
			

func use_card(cardView):
	var cards_playable_per_turn = self.game.human.compute("cards_playable_per_turn")
	Utils.log("Cards Playable per turn: %s" % cards_playable_per_turn)
	if cards_playable_per_turn != -1 and self.game.human.resources.cards_played >= cards_playable_per_turn:
		messenger.set_message("You cannot play any more cards this turn.")
		return
	self.used_card = cardView
	cardView.highlight(true)
	
	Utils.log("Card %s used" % cardView.card.name)
	var play_powers = cardView.card.effects.filter(func(e): return e.type == Effect.Type.Power)
	if play_powers.size() > 0:
		var play_power = play_powers[0]
		match play_power.name:
			"reinforcements":
				set_reinforcements(play_power.value)
			"sacrifice":
				set_sacrifice()
			"build":
				set_building(play_power.value)
			"sink":
				var s = Shape.new()
				s.init_with_json_coords(play_power.value)
				s.add_bonus(self.game.human.compute("flat_sink_bonus"))
				set_shape(s.coords.keys(), MouseState.Sink)
			"emerge":
				var s = Shape.new()
				s.init_with_json_coords(play_power.value)
				s.add_bonus(self.game.human.compute("flat_emerge_bonus"))
				set_shape(s.coords.keys(), MouseState.Emerge)
	else:
		self.card_used(cardView)

	
func card_used(cv):
	for effect in cv.card.effects.filter(func(e): return e.type != Effect.Type.Power):
		await Effects.add(effect)
	self.game.human.resources.faith -= cv.card.cost
	self.update_faith_player()
	self.used_card = null
	self.game.human.resources.cards_played += 1
	Effects.trigger(Effect.Trigger.CardPlayed)
	if cv.card.exhaust:
		self.deck.exhaust(cv)
	else:
		self.deck.discard(cv)
	
	

func closest_player_tile_coords():
	var closest_player_tile = Constants.NULL_COORDS
	var closest_tile_distance = 100000
	var camera_tile = self.world.local_to_map(self.world.camera.position)
	for region in self.world.regions:
		if self.world.regions[region].data.team == self.game.human.team:
			var center_tile = self.world.regions[region].center_tile()
			var distance = Utils.distance(center_tile, camera_tile)
			if distance < closest_tile_distance:
				closest_player_tile = center_tile
				closest_tile_distance = distance
	return closest_player_tile
	

func check_win_condition():
	for player in self.game.players:
		if not regions_left(player.team) and not player.eliminated:
			player.eliminated = true
			messenger.set_message(Constants.TEAM_NAMES[player.team] + " has been wiped from the island!")
	if self.game.human.eliminated:
		Info.lost = true
		await SceneTransition.change_scene(SceneTransition.SCENE_REWARD)
	elif self.game.players.filter(func(p): return !p.eliminated).size() < 2:
		await SceneTransition.change_scene(SceneTransition.SCENE_REWARD)

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
	if self.game.current_player.is_bot:
		clear_mouse_state()
		return
	if clicked_region.data.is_used:
		clear_mouse_state()
		return
	if selected_region != null and clicked_region.data.id == selected_region:
		clear_mouse_state()
		return
	if selected_region == null:
		if clicked_region.data.team == self.game.human.team:
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
				var move = Action.new(self.game.human.team, Action.Type.Move, selected_region, clicked_region.data.id )
				self.game.actions_history.append(move)
				self.apply_action(move)
			else:
				messenger.set_message("My lord, we cannot leave this region undefended!")
			clear_mouse_state()

func play_global_turn():
	await self.game.next_turn()
	world.path_lengths.clear()
	world.path_lengths = world.all_path_lengths()
	while self.game.current_player != self.game.human:
		self.messenger.set_message(Constants.TEAM_NAMES[self.game.current_player.team] + " is making their move...")
		generate_units(self.game.current_player.team)
		await play_turn()
		self.game.next_player()

	await self.world.sink_marked()
	check_win_condition()
	await self.world.mark_tiles(self.game.global_turn)
	

func prepare_turn():
	self.generate_units(self.game.human.team)
	self.game.human.resources.faith = self.game.human.compute("faith_per_turn") + self.world.tiles.values().filter(func(t): return t.data.team == self.game.human.team and t.data.building == Constants.Building.Temple).size()
	self.game.human.resources.card_played = 0
	self.update_faith_player()
	await self.deck.draw_multiple(self.game.human.compute("cards_per_turn"))
	self.deck.update_faith(self.game.human.resources.faith)

func play_turn():
	var playing = true
	while playing:
		var thread = Thread.new()
		thread.start(self.game.current_player.bot.play_turn.bind(self.world))
		while thread.is_alive():
			await Utils.wait(0.1)
		# var bot_actions = thread.wait_to_finish()
		var bot_actions = self.game.current_player.bot.play_turn(self.world) ## use for debugging
		for bot_action in bot_actions:
			if bot_action.action == Action.Type.None:
				playing = false
				break
			await apply_action(bot_action)
			self.game.actions_history.append(bot_action)
			await Utils.wait(Settings.turn_time)
	self.apply_buildings(self.game.current_player.team)
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
			world.regions[region].generate_units(self.game.current_player.compute("units_per_tile"))

func apply_action(action : Action):
	match action.action:
		Action.Type.Move:
			await self.world.move_units(action.region_from, action.region_to, action.team)
		Action.Type.Sink:
			await self.world.sink_tiles(action.tiles)
			Effects.trigger(Effect.Trigger.TileSunk)
		Action.Type.Emerge:
			await self.world.emerge_tiles(action.tiles)
			Effects.trigger(Effect.Trigger.TileEmerged)
		Action.Type.Sacrifice:
			sacrifice_region(action.region_from, action.team)
			Effects.trigger(Effect.Trigger.RegionSacrificed)
		Action.Type.Build:
			self.world.tiles[action.tiles[0]].set_building(action.misc)
			Effects.trigger(Effect.Trigger.BuildingBuilt)
		Action.Type.Reinforce:
			self.world.regions[action.region_from].data.units += action.misc
			if self.world.regions[action.region_from].data.team == Constants.NULL_TEAM:
				self.world.regions[action.region_from].set_team(self.game.human.team)
			self.world.regions[action.region_from].update()
			Effects.trigger(Effect.Trigger.RegionReinforced)
		Action.Type.None:
			pass
		_:
			Utils.log("Unknown action: %s" % action)
	check_win_condition()

func update_faith_player():
	self.deck.update_faith(self.game.human.resources.faith)
	self.faith_label.set_text(str(self.game.human.resources.faith) + "/" + str(self.game.human.resources.faith_per_turn))

func load_map(map_regions):
	self.world.clear_island()
	self.world.load_regions(map_regions)
	for region in self.world.regions.values():
		if region.data.team != Constants.NULL_TEAM and region.data.team != self.game.human.team:
			region.generate_units(self.game.player_from_team(region.data.team).compute("units_per_tile"))

func set_shape(shape_coords, mode):
	self.mouse_item = shape_prefab.instantiate()
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

func set_reinforcements(new_reinforcements):
	self.mouse_item = Sprite2D.new()
	self.mouse_item.texture = load("res://assets/icons/Plus.png")
	self.current.reinforcements = new_reinforcements + self.game.current_player.compute("flat_reinforce_bonus")
	self.world.add_child(mouse_item)
	self.mouse_item.global_position = get_viewport().get_mouse_position()
	self.mouse_state = MouseState.Reinforce

func set_building(building):
	var b = Constants.BUILDING_ENUM[building]
	self.mouse_item = Sprite2D.new()
	self.mouse_item.texture = Constants.BUILDINGS[b].texture
	self.current.building = b
	self.world.add_child(mouse_item)
	self.mouse_item.global_position = get_viewport().get_mouse_position()
	self.mouse_state = MouseState.Build

func fast_forward(val):
	Settings.skip(val)
	self.world.camera.skip(val)
	self.fastForwardButton.button_pressed = val

			
func sacrifice_region(region_id, team_id):
	if self.world.regions[region_id].data.team == team_id:
		# self.add_faith(team_id, self.world.regions[region_id].sacrifice())
		self.world.regions[region_id].sacrifice()
		#self.add_cards(2)
		messenger.set_message("%s has sacrificed a region's inhabitants to the gods!" % Constants.TEAM_NAMES[team_id])
	else:
		Utils.log("Trying to sacrifice region %s, but it belongs to team %s" % [region_id, self.world.regions[region_id].data.team])

func _on_fast_forward_button_toggled(button_pressed:bool):
	fast_forward(button_pressed)

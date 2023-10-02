extends Node2D

var turnIndicatorPrefab = preload("res://ui/turn_indicator.tscn")
var escMenuPrefab = preload("res://scenes/esc_menu.tscn")

@onready var UI = $"%UI"
@onready var SelectionUI = $"%SelectionUI"
@onready var world = $"%World"
@onready var turnContainer = $"%TurnContainer"
@onready var turnLabel = $"%TurnLabel"
@onready var messager = $"%Message"
@onready var endTurnButton = $"%TurnButton"


var selected_region = null
var teams = []
var turn = 0
var player_team_index = 0
var global_turn = 0

var actions_history = []
var bots = {}

var turn_indicators = []
var selected_team_num = 7

var game_started = false
var escMenu = null

func to_team_id(team_id):
	return team_id + 1

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.visible = false
	SelectionUI.visible = true
	self.world.init_world()
	self.gen_world()

func gen_world():
	self.world.clear_island()
	self.world.generate_island()
	self.add_teams()
	for r in self.world.regions.values():
		r.units = 0
	for t in self.teams:
		generate_units(t)

func add_teams():
	self.teams.clear()
	self.bots.clear()
	for t in self.turn_indicators:
		t.queue_free()
	self.turn_indicators.clear()
	for i in range(0, self.selected_team_num):
		var team_id = to_team_id(i)
		self.teams.append(team_id)
		self.bots[team_id] = DumbBot.new(team_id)
		self.world.add_team(team_id)
		self.create_turn_indicator(team_id)

func start_game():
	self.game_started = true
	self.SelectionUI.visible = false
	self.UI.visible = true


func create_turn_indicator(team_id):
	var turnIndicator = turnIndicatorPrefab.instantiate()
	turnIndicator.init(Color.hex(Constants.TEAM_COLORS[team_id]), false if team_id > 1 else true)
	turnContainer.add_child(turnIndicator)
	self.turn_indicators.append(turnIndicator)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _unhandled_input(event):
	if event.is_action_pressed("escmenu"):
		if escMenu == null:
			escMenu = escMenuPrefab.instantiate()
			self.add_child(escMenu)
		else:
			escMenu.delete()
	elif event is InputEventMouseButton:
		if Settings.input_locked or !game_started:
			return
		var coords_clicked = world.global_pos_to_coords(event.position)
		if world.tiles.has(coords_clicked):
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				on_tile_clicked(world.tiles[coords_clicked])

func _on_turn_button_pressed():
	self.endTurnButton.disabled = true
	await next_turn()
	
func check_global_turn_over():
	return self.turn == self.teams.size() - 1

func check_win_condition():
	var teams_alive = get_teams_alive()
	check_last_team_alive(teams_alive)
	check_teams_on_islands(teams_alive)

func check_last_team_alive(teams_alive):
	if teams_alive.size() == 1:
		print("Player " + str(teams_alive[0]) + " won!")

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
		print("No more possible moves! ", winner, " won with ", winning_units, " units!")

func get_teams_alive():
	var teams_alive = []
	for team in teams:
		if regions_left(team):
			teams_alive.append(team)
	return teams_alive

func bots_play():
	var bot_action = null
	var bot = self.bots[to_team_id(self.turn)]
	while bot_action == null or bot_action.action != Constants.Action.NONE:
		bot_action = bot.play_turn(self.world)
		await apply_action(bot_action)
		self.actions_history.append(bot_action)
		await Utils.wait(Constants.TURN_TIME)
	self.world.clear_regions_used()

func clear_selected_region():
	if selected_region != null:
		self.world.regions[selected_region].set_selected(false)
		self.selected_region = null
	

func on_tile_clicked(new_clicked_tile):
	if !(self.turn == self.player_team_index):
		clear_selected_region()
		return
	if new_clicked_tile.region in self.world.regions_used:
		clear_selected_region()
		return
	if selected_region != null and new_clicked_tile.region == selected_region:
		clear_selected_region()
		return
	if selected_region == null:
		if new_clicked_tile.team == self.teams[self.player_team_index]:
			self.selected_region = new_clicked_tile.region
			self.world.regions[selected_region].set_selected(true)
	else:
		if new_clicked_tile.region not in self.world.adjacent_regions(self.selected_region):
			clear_selected_region()
			return
		else:
			var move = Action.new(self.teams[self.player_team_index], Constants.Action.MOVE, selected_region, new_clicked_tile.region )
			actions_history.append(move)
			self.apply_action(move)
			clear_selected_region()
	

func next_turn():
	self.world.clear_regions_used()
	Settings.input_locked = true
	if check_global_turn_over():
		self.global_turn += 1
		await turn_events()
	self.turn = (self.turn + 1) % (self.teams.size())
	for i in range(self.teams.size()):
		self.turn_indicators[i].set_active(self.turn == i)
	check_win_condition()
	generate_units(teams[self.turn])
	if not regions_left(self.teams[self.turn]):
		await next_turn()
	elif (self.turn != self.player_team_index):
		await bots_play()
		await Utils.wait(Constants.TURN_TIME)
		await next_turn()
	Settings.input_locked = false
	self.endTurnButton.disabled = false
	self.turnLabel.set_text("Turn: " + str(self.global_turn))
	

func turn_events():
	await world.generate_disaster()
	await Utils.wait(Constants.TURN_TIME)


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
	if action.action == Constants.Action.NONE:
		return
	if action.action == Constants.Action.MOVE:
		await self.world.move_units(action.region_from, action.region_to, action.team)


func _on_team_num_value_changed(value:float):
	self.selected_team_num = int(value)
	self.gen_world()


func _on_generate_btn_pressed():
	self.gen_world()


func _on_play_btn_pressed():
	self.start_game()

extends Node2D

@onready var world = $"%World"
@onready var teamTurnRect = $"%TeamTurn"

var selected_region = null
var teams = []
var turn = 0
var player_team_index = 0
var global_turn = 0

var actions_history = []
var bots = {}
var regions_used = []


func to_team_id(team_id):
	return team_id + 1

# Called when the node enters the scene tree for the first time.
func _ready():
	self.world.init_world()
	var teams_num = randi_range(Constants.MIN_TEAMS, Constants.MAX_TEAMS)
	self.teams.append(to_team_id(0))
	self.world.add_team(to_team_id(0))
	for i in range(1, teams_num):
		var team_id = to_team_id(i)
		self.teams.append(team_id)
		self.bots[team_id] = DumbBot.new(team_id)
		self.world.add_team(team_id)
	generate_units(self.teams[0])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	if Settings.input_locked:
		return
	if event is InputEventMouseButton:
		var coords_clicked = world.global_pos_to_coords(event.position)
		if world.tiles.has(coords_clicked):
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				on_tile_clicked(world.tiles[coords_clicked])
			# if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# 	world.set_cell(1, world.global_pos_to_coords(event.position), -1, Vector2i(0,0), 0)
			# 	var region_clicked = world.tiles[coords_clicked].region
			# 	world.delete_cell(coords_clicked)
			# 	world.recalculate_region(region_clicked)

func _on_turn_button_pressed():
	await next_turn()
	
func check_global_turn_over():
	return self.turn == self.teams[self.player_team_index]

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
	Settings.input_locked = true
	if check_global_turn_over():
		self.global_turn += 1
		await turn_events()
	self.turn = (self.turn + 1) % (self.teams.size())
	self.teamTurnRect.color = Constants.TEAM_COLORS[to_team_id(self.turn)]
	self.world.clear_regions_used()
	check_win_condition()
	generate_units(teams[self.turn])
	await turn_events()
	if not regions_left(self.teams[self.turn]):
		await next_turn()
	elif (self.turn != self.player_team_index):
		await Utils.wait(Constants.TURN_TIME)
		await bots_play()
		await next_turn()
	Settings.input_locked = false
	

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
		await self.world.move_units(action.region_from, action.region_target, action.team == self.teams[self.player_team_index])

extends Node2D

@onready var world = $"%World"
@onready var coordsLabel = $"%Coordinates"
@onready var teamLabel = $"%TeamLabel"
@onready var turnLabel = $"%TurnLabel"
@onready var regionLabel = $"%RegionLabel"
@onready var teamTurnRect = $"%TeamTurn"

var clicked_tile = null
var teams = []
var turn = 0
var inspect_mode = false
var player_team_index = 0

var actions_history = []
var bots = {}
var regions_used = {}


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
	if event is InputEventMouseButton:
		var coords_clicked = world.global_pos_to_coords(event.position)
		if world.tiles.has(coords_clicked):
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				# var new_tile = tile.new(global_pos_to_coords(event.position), 1)
				# self.update_cell(new_tile)
				
					on_tile_clicked(world.tiles[coords_clicked])
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				world.set_cell(1, world.global_pos_to_coords(event.position), -1, Vector2i(0,0), 0)
				var region_clicked = world.tiles[coords_clicked].region
				world.delete_cell(coords_clicked)
				world.recalculate_region(region_clicked)

func _on_turn_button_pressed():
	next_turn()
	check_win_condition()
	generate_units(teams[self.turn])
	update_display()
	world.generate_disaster()
	if (self.turn != self.player_team_index):
		await get_tree().create_timer(Constants.TURN_TIME).timeout
		bots_play()
		await get_tree().create_timer(Constants.TURN_TIME).timeout
		_on_turn_button_pressed()
	
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
		bot_action = bot.play_turn(self.world, self.regions_used)
		apply_action(bot_action)
		self.actions_history.append(bot_action)
		await get_tree().create_timer(Constants.TURN_TIME).timeout

func _on_inspect_button_toggled(pressed: bool):
	inspect_mode = pressed;

func on_tile_clicked(new_clicked_tile):
	if (inspect_mode):
		clicked_tile = new_clicked_tile;
		update_display()
		return
	if (self.turn == self.player_team_index and clicked_tile != null and clicked_tile.team == self.teams[player_team_index] and clicked_tile.region != new_clicked_tile.region):
		var moved = self.world.move_units(clicked_tile.region, new_clicked_tile.region)
		self.world.regions[clicked_tile.region].set_selected(false)
		self.regions_used[clicked_tile.region] = moved
		clicked_tile = null
	else:
		if self.regions_used.has(new_clicked_tile.region) and self.regions_used[new_clicked_tile.region]:
			print("Error: this region has already been used this turn", new_clicked_tile.region)
		else:
			if (new_clicked_tile.team == self.teams[self.player_team_index]):
				clicked_tile = new_clicked_tile
				self.world.regions[clicked_tile.region].set_selected(true)
			else:
				clicked_tile = null
	update_display()


func update_display():
	print(clicked_tile)
	if (clicked_tile != null):
		coordsLabel.text = str(clicked_tile.coords)
		teamLabel.text = str(clicked_tile.team)
		regionLabel.text = str(clicked_tile.region)
	turnLabel.text = str(teams[self.turn])

func next_turn():
	self.turn = (self.turn + 1) % (self.teams.size())
	self.teamTurnRect.color = Constants.TEAM_COLORS[to_team_id(self.turn)]
	for region in regions_used:
		self.world.regions[region].set_used(false)
	self.regions_used.clear()
	if not regions_left(self.teams[self.turn]):
		next_turn()
	

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
		self.regions_used[action.region_from] = self.world.move_units(action.region_from, action.region_target)

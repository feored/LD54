extends Node2D


@onready var world = $"World"
var teams = []
var selected_team_num = 7


# Called when the node enters the scene tree for the first time.
func _ready():
	self.world.init(Callable())
	self.gen_world()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add_teams():
	self.world.reset_regions_team()
	self.teams.clear()
	for i in range(0, self.selected_team_num):
		var team_id = Utils.to_team_id(i)
		self.teams.append(team_id)
		self.world.add_team(team_id)


func gen_world():
	self.world.clear_island()
	self.world.generate_island()
	self.add_teams()


func _on_team_num_value_changed(value: float):
	self.selected_team_num = int(value)
	self.add_teams()


func _on_generate_btn_pressed():
	self.gen_world()


func get_save_data():
	var saved_tiles = {}
	var saved_regions = {}
	for coords in self.world.tiles:
		saved_tiles[var_to_str(coords)] = self.world.tiles[coords].get_save_data()
	for region in self.world.regions:
		saved_regions[region] = self.world.regions[region].get_save_data()
	return Utils.to_map_object(saved_tiles, saved_regions, teams.duplicate())

func _on_play_btn_pressed():
	Settings.current_map = get_save_data()
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_GAME)

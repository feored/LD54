extends Node2D


@onready var world = $"World"
@onready var island_size_slider = $"%IslandSizeSlider"
@onready var instant_button = $"%InstantButton"

var teams = []
var selected_team_num = 7
var island_size = Constants.ISLAND_SIZE_DEFAULT


# Called when the node enters the scene tree for the first time.
func _ready():
	island_size_slider.min_value = Constants.ISLAND_SIZE_MIN
	island_size_slider.max_value = Constants.ISLAND_SIZE_MAX
	island_size_slider.value = island_size
	instant_button.button_pressed = Settings.get_setting(Settings.Setting.InstantMap)
	self.world.init(Callable())
	self.gen_world()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func add_teams():
	self.world.reset_regions_team()
	self.teams.clear()
	for i in range(0, self.selected_team_num):
		var team_id = Utils.to_team_id(i)
		self.teams.append(team_id)
		self.world.add_team(team_id)


func gen_world():
	await self.world.clear_island()
	await self.world.generate_island(island_size, Settings.get_setting(Settings.Setting.InstantMap))
	self.add_teams()


func _on_team_num_value_changed(value: float):
	self.selected_team_num = int(value)
	self.add_teams()


func _on_generate_btn_pressed():
	await self.gen_world()


func _on_play_btn_pressed():
	Settings.current_map = Utils.get_save_data(self.world, self.teams)
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_GAME)


func _on_island_size_slider_value_changed(value):
	island_size = value


func _on_island_size_slider_drag_ended(value_changed):
	if value_changed:
		self.gen_world()


func _on_instant_button_toggled(button_pressed:bool):
	Settings.set_setting(Settings.Setting.InstantMap, button_pressed)

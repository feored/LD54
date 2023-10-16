extends Node2D

@onready var world = $"World"
@onready var center = $"%Center"


var is_drawing = false
var is_erasing = false
var is_placing_team = false

var current_team_place = 1
var highest_team_place = 1

var teams = []



# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.input_locked = false
	self.world.init(Callable())
	self.center.position = self.world.coords_to_pos(Constants.WORLD_CENTER)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			draw_or_erase_or_team(event)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			is_drawing = false
			is_erasing = false
			is_placing_team = false

func draw_or_erase_or_team(event):
	var coords_clicked = self.world.global_pos_to_coords(event.position)
	if is_drawing:
		if !world.tiles.has(coords_clicked):
			world.spawn_cell(coords_clicked, 0)
	elif is_erasing:
		if world.tiles.has(coords_clicked):
			world.remove_cell(coords_clicked)
	elif is_placing_team:
		if world.tiles.has(coords_clicked):
			var region = world.tiles[coords_clicked].region
			self.world.regions[region].set_team(self.current_team_place)
			if self.highest_team_place < self.current_team_place:
				self.highest_team_place = self.current_team_place
			self.teams.clear()
			for i in range(1, self.highest_team_place+1):
				self.teams.append(i)
			self.is_placing_team = false

func save():
	var save_game = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	save_game.store_line(JSON.stringify(get_save_data()))
	print("Saved game")
	save_game.close()

func get_save_data():
	var saved_tiles = {}
	var saved_regions = {}
	for coords in self.world.tiles:
		saved_tiles[var_to_str(coords)] = self.world.tiles[coords].get_save_data()
	for region in self.world.regions:
		saved_regions[region] = self.world.regions[region].get_save_data()
	return Utils.to_map_object(saved_tiles, saved_regions, teams.duplicate())


func load_saved_game():
	var save_game = FileAccess.open("user://savegame.json", FileAccess.READ)
	var saved_state = JSON.parse_string(save_game.get_line())
	save_game.close()
	self.world.clear_island()
	self.teams = saved_state.teams
	self.world.load_tiles(saved_state.tiles)
	self.world.load_regions(saved_state.regions)


func _on_load_btn_pressed():
	load_saved_game()

func _on_reset_btn_pressed():
	self.world.clear_island()


func _on_erase_btn_pressed():
	self.is_erasing = true
	self.is_drawing = false
	self.is_placing_team = false

func _on_draw_btn_pressed():
	self.is_drawing = true
	self.is_erasing = false
	self.is_placing_team = false
	
func _on_regions_btn_pressed():
	var tiles = self.world.tiles.keys().duplicate()
	self.world.clear_island()
	for t in tiles:
		self.world.spawn_cell(t, 0)
	self.world.generate_regions()
	self.world.apply_borders()


func _on_place_team_num_value_changed(value):
	current_team_place = int(value)


func _on_place_team_btn_pressed():
	self.is_drawing = false
	self.is_erasing = false
	self.is_placing_team = true


func _on_save_btn_pressed():
	save()

func _on_center_btn_pressed():
	await self.world.camera.move_smoothed(self.world.coords_to_pos(Constants.WORLD_CENTER), 5)


func _on_play_btn_pressed():
	Settings.current_map = get_save_data()
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_GAME)

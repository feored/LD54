extends Node2D

@onready var world = $"World"
@onready var center = $"%Center"
@onready var cursor = %MouseCursor

const COLOR_VALID = Color(0, 1, 0, 0.75)
const COLOR_INVALID = Color(1, 0, 0, 0.75)
const COLOR_DELETE = Color(1, 0.25, 0, 0.75)
const COLOR_INVISIBLE = Color(0, 0, 0, 0)
const TEXTURE_HEX = preload("res://assets/tiles/hex_shape.png")


enum State {
	None,
	Drawing,
	Erasing,
	PlacingTeam,
	PlacingRegion
}

var state = State.None
var current_team_place = 1
var highest_team_place = 1

var clicking = false

var teams = []



# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.input_locked = false
	self.world.init(Callable())
	self.center.position = self.world.coords_to_pos(Constants.WORLD_CENTER)

func set_state(state):
	self.state = state
	match state:
		State.Drawing:
			self.cursor.scale = Vector2(1, 1)
			self.cursor.texture = TEXTURE_HEX
			self.cursor.visible = true
			self.cursor.modulate = COLOR_INVALID
		State.Erasing:
			self.cursor.scale = Vector2(1, 1)
			self.cursor.texture = TEXTURE_HEX
			self.cursor.visible = true
			self.cursor.modulate = COLOR_INVISIBLE
		State.PlacingTeam:
			self.cursor.scale = Vector2(0.5, 0.5)
			self.cursor.texture = TEXTURE_HEX
			self.cursor.visible = true
			self.cursor.modulate = Constants.TEAM_COLORS[self.current_team_place]
		State.None:
			self.cursor.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
		
func _unhandled_input(event):
	if event.is_action_pressed("right_click"):
		set_state(State.None)
		return
	if event.is_action_pressed("left_click"):
		clicking = true
		self.world.camera.active = false
	elif event.is_action_released("left_click"):
		clicking = false
		self.world.camera.active = true
	if event is InputEventMouseMotion and state != State.None:
		var coords = self.world.global_pos_to_coords(event.position)
		self.cursor.position = self.world.coords_to_pos(coords)

	match self.state:
		State.None:
			return
		State.Drawing:
			draw(event)
		State.Erasing:
			erase(event)
		State.PlacingTeam:
			place_team(event)

func draw(event):
	var coords = self.world.global_pos_to_coords(event.position)
	if world.tiles.has(coords):
		self.cursor.modulate = COLOR_INVALID
	else:
		self.cursor.modulate = COLOR_VALID

	if clicking:
		if !world.tiles.has(coords):
			world.spawn_cell(coords, 0)

func erase(event):
	var coords = self.world.global_pos_to_coords(event.position)
	if world.tiles.has(coords):
		self.cursor.modulate = COLOR_DELETE
	else:
		self.cursor.modulate = COLOR_INVISIBLE
	if clicking:
		if world.tiles.has(coords):
			world.remove_cell_instant(coords)

func place_team(event):
	var coords = self.world.global_pos_to_coords(event.position)
	if event.is_action_pressed("left_click"):
		if world.tiles.has(coords):
			var region = world.tiles[coords].region
			self.world.regions[region].set_team(self.current_team_place)
			if self.highest_team_place < self.current_team_place:
				self.highest_team_place = self.current_team_place
			self.teams.clear()
			for i in range(1, self.highest_team_place+1):
				self.teams.append(i)
			self.set_state(State.None)

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
	self.set_state(State.Erasing)

func _on_draw_btn_pressed():
	self.set_state(State.Drawing)
	
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
	self.set_state(State.PlacingTeam)


func _on_save_btn_pressed():
	save()

func _on_center_btn_pressed():
	await self.world.camera.move_smoothed(self.world.coords_to_pos(Constants.WORLD_CENTER), 5)


func _on_play_btn_pressed():
	Settings.current_map = get_save_data()
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_GAME)

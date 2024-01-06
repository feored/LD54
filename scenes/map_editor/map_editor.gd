extends Node2D

@onready var world = $"World"
@onready var cursor = %MouseCursor
@onready var drawing_UI = %"DrawingUI"
@onready var teams_UI = %"TeamsUI"
@onready var next_stage_btn = %"NextStageBtn"
@onready var prev_stage_btn = %"PreviousStageBtn"
@onready var play_btn = %"PlayBtn"
@onready var save_btn = %"SaveBtn"
@onready var pick_building_btn = %"PickBuildingBtn"
@onready var grid = %SavedMapsGrid
@onready var loader = %Loader

const COLOR_VALID = Color(0, 1, 0, 0.75)
const COLOR_INVALID = Color(1, 0, 0, 0.75)
const COLOR_DELETE = Color(1, 0.25, 0, 0.75)
const COLOR_INVISIBLE = Color(0, 0, 0, 0)
const COLOR_REGION = Color(0.5, 0.5, 0.5, 0.5)
const COLOR_DEFAULT = Color(1, 1, 1, 1)

const TEXTURE_HEX = preload("res://assets/tiles/hex_shape.png")

enum EditStage {
	Drawing,
	Teams
}

enum State {
	None,
	Drawing,
	Erasing,
	PlacingTeam,
	PlacingRegion,
	PlacingBuilding
}

var edit_stage = EditStage.Drawing
var state = State.None
var current_team_place = 1
var highest_team_place = 1

var clicking = false

var teams = []
var map_name = ""

## placing regions
var current_region_id = 0

## placing buildings
var selected_building = Constants.Building.Barracks



# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.input_locked = false
	self.world.init(Callable())
	self.init_building_button()
	#self.world.regionLabelsParent.hide()
	self.set_stage(EditStage.Drawing)
	

func init_building_button():
	for b in Constants.BUILDINGS.keys():
		self.pick_building_btn.add_icon_item(Constants.BUILDINGS[b].texture, Constants.BUILDINGS[b].name, b as int)

func set_stage(new_stage):
	self.edit_stage = new_stage
	match new_stage:
		EditStage.Drawing:
			self.drawing_UI.show()
			self.teams_UI.hide()
			Settings.editor_tile_distinct_mode = true
			check_drawing_valid()
		EditStage.Teams:
			self.drawing_UI.hide()
			self.teams_UI.show()
			Settings.editor_tile_distinct_mode = false
			check_teams_valid()
	for t in self.world.tiles.values():
		t.update()
	self.set_state(State.None)

func set_state(state):
	self.state = state
	match state:
		State.PlacingRegion:
			self.current_region_id = self.world.region_new_id()
			self.world.spawn_region(self.current_region_id)
			self.cursor.scale = Vector2(1, 1)
			self.cursor.texture = TEXTURE_HEX
			self.cursor.visible = true
			self.cursor.modulate = COLOR_REGION
		State.PlacingBuilding:
			self.cursor.scale = Vector2(1, 1)
			self.cursor.texture = Constants.BUILDINGS[self.selected_building].texture
			self.cursor.visible = true
			self.cursor.modulate = COLOR_DEFAULT
		State.Drawing:
			self.current_region_id = self.world.region_new_id()
			self.world.spawn_region(self.current_region_id)
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
	if event is InputEventMouse:
		match self.state:
			State.None:
				return
			State.Drawing:
				draw(event)
			State.Erasing:
				erase(event)
			State.PlacingTeam:
				place_team(event)
			State.PlacingRegion:
				place_region(event)
			State.PlacingBuilding:
				place_building(event)

func place_building(event):
	var coords = self.world.global_pos_to_coords(event.position)
	if world.tiles.has(coords) and self.world.tiles[coords].data.building == Constants.Building.None:
		self.cursor.modulate = COLOR_VALID
	else:
		self.cursor.modulate = COLOR_INVALID
		return
	if clicking:
		self.world.tiles[coords].set_building(Constants.BUILDINGS[self.selected_building].id)
		self.set_state(State.None)

func place_region(event):
	var coords = self.world.global_pos_to_coords(event.position)
	if world.tiles.has(coords):
		self.cursor.modulate = COLOR_REGION
	else:
		self.cursor.modulate = COLOR_INVALID
		return
	if clicking and self.world.tiles[coords].data.region != current_region_id:
		var old_region = self.world.tiles[coords].data.region
		self.world.regions[old_region].remove_tile(coords, true)
		self.world.regions[current_region_id].add_tile(self.world.tiles[coords], false)
		self.world.recalculate_region(current_region_id)
		self.world.recalculate_region(old_region)
		self.check_drawing_valid()
		for r in self.world.regions.values():
			Utils.log("Region " + str(r.data.id) + " has " + str(r.data.tiles.size()) + " tiles")

func draw(event):
	var coords = self.world.global_pos_to_coords(event.position)
	if world.tiles.has(coords):
		self.cursor.modulate = COLOR_INVALID
		return
	else:
		self.cursor.modulate = COLOR_VALID

	if clicking:
			self.world.regions[current_region_id].spawn_cell(coords, 0)
			self.world.regions[current_region_id].update()
			self.check_drawing_valid()

func erase(event):
	var coords = self.world.global_pos_to_coords(event.position)
	if world.tiles.has(coords):
		self.cursor.modulate = COLOR_DELETE
	else:
		self.cursor.modulate = COLOR_INVISIBLE
		return
	if clicking:
		self.world.tiles[coords].delete()

func place_team(event):
	var coords = self.world.global_pos_to_coords(event.position)
	if event.is_action_pressed("left_click"):
		if world.tiles.has(coords):
			var region = world.tiles[coords].data.region
			self.world.regions[region].set_team(self.current_team_place)
			if self.highest_team_place < self.current_team_place:
				self.highest_team_place = self.current_team_place
			self.teams.clear()
			for i in range(1, self.highest_team_place+1):
				self.teams.append(i)
			self.set_state(State.None)
			self.check_teams_valid()

func save(savename = "savegame.json"):
	if !DirAccess.dir_exists_absolute(Constants.USER_MAPS_PATH):
		DirAccess.make_dir_absolute(Constants.USER_MAPS_PATH)
	var save_game = FileAccess.open(Constants.USER_MAPS_PATH + savename, FileAccess.WRITE)
	save_game.store_line(JSON.stringify(Utils.get_save_data(self.world, self.teams)))
	save_game.close()




func load_saved_game(filename):
	var save_game = FileAccess.open(Constants.USER_MAPS_PATH + filename, FileAccess.READ)
	var saved_state = JSON.parse_string(save_game.get_line())
	save_game.close()
	self.world.clear_island()
	self.teams = saved_state.teams
	self.world.load_regions(saved_state.regions)
	self.set_stage(EditStage.Teams)

func drawing_valid():
	if self.world.tiles.size() < 2 or self.world.regions.size() < 2:
		return false
	return true

func check_drawing_valid():
	self.next_stage_btn.disabled = !drawing_valid()

func check_teams_valid():
	var valid = teams_valid()
	self.save_btn.disabled = !valid
	self.play_btn.disabled = !valid


func teams_valid():
	if map_name == "":
		return false
	if self.teams.size() < 2:
		return false
	return true


func _on_load_button_pressed():
	if DirAccess.dir_exists_absolute(Constants.USER_MAPS_PATH):
		for m in DirAccess.get_files_at(Constants.USER_MAPS_PATH):
			var l = Label.new()
			l.text = m
			grid.add_child(l)
			var b = Button.new()
			b.text = "Load"
			b.pressed.connect(func(): load_saved_game(m); self.loader.hide())
			grid.add_child(b)
	self.loader.show()


func _on_reset_btn_pressed():
	self.world.clear_island()


func _on_erase_btn_pressed():
	self.set_state(State.Erasing)

func _on_draw_btn_pressed():
	self.set_state(State.Drawing)
	
func _on_regions_btn_pressed():
	# var tiles = self.world.tiles.keys().duplicate()
	# self.world.clear_island()
	# for t in tiles:
	# 	self.world.spawn_cell(t, 0)
	self.world.generate_regions()
	self.check_drawing_valid()



func _on_place_team_num_value_changed(value):
	current_team_place = int(value)


func _on_place_team_btn_pressed():
	self.set_state(State.PlacingTeam)


func _on_save_btn_pressed():
	save(self.map_name + ".json")

func _on_center_btn_pressed():
	await self.world.camera.move_smoothed(self.world.coords_to_pos(Constants.WORLD_CENTER), 5)


func _on_play_btn_pressed():
	Settings.current_map = Utils.get_save_data(self.world, self.teams)
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_GAME)


func _on_manual_territory_btn_pressed():
	self.set_state(State.PlacingRegion)



func _on_next_stage_pressed():
	if drawing_valid():
		self.set_stage(EditStage.Teams)

func _on_previous_stage_btn_pressed():
	self.set_stage(EditStage.Drawing)
	

func _on_buildingbtn_pressed():
	self.set_state(State.PlacingBuilding)


func _on_pick_building_btn_item_selected(index):
	self.selected_building = index+1

func _on_return_button_pressed():
	self.loader.hide()


func _on_map_name_edit_text_changed(new_text):
	self.map_name = new_text
	self.check_teams_valid()

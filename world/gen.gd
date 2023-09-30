extends TileMap

@onready var camera = $Camera2D
@onready var coordsLabel = $"%Coordinates"
@onready var unitsLabel = $"%Units"
@onready var teamLabel = $"%TeamLabel"

var clicked_tile = null
var tile = load("res://world/tile.gd")
var tiles = {}


func update_cell(changed_tile):
	if not tiles.has(changed_tile.coords):
		tiles[changed_tile.coords] = changed_tile
	var alt = changed_tile.team if changed_tile.tile_type == 1 else 0
	self.set_cell(0, changed_tile.coords, changed_tile.tile_type, Vector2i(0, 0), alt)


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(-Constants.WORLD_BOUNDS.x, Constants.WORLD_BOUNDS.x):
		for j in range(-Constants.WORLD_BOUNDS.y, Constants.WORLD_BOUNDS.y):
			var land = (randi() % 2)
			var team = (randi() % 3) + 1 if land else 0
			var new_tile = tile.new(Vector2i(Constants.WORLD_CENTER.x + i, Constants.WORLD_CENTER.y + j), land, team)
			update_cell(new_tile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# var new_tile = tile.new(global_pos_to_coords(event.position), 1)
			# self.update_cell(new_tile)
			var coords_clicked = global_pos_to_coords(event.position)
			if self.tiles.has(coords_clicked):
				clicked_tile = self.tiles[coords_clicked]
				coordsLabel.text = str(clicked_tile.coords)
				unitsLabel.text = str(clicked_tile.units)
				teamLabel.text = str(clicked_tile.team)
			else:
				print(coords_clicked)
				print(self.tiles.keys())
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var new_tile = tile.new(global_pos_to_coords(event.position), 0, 0)
			self.update_cell(new_tile)


func get_real_pos(pos):
	return Vector2(pos.x + camera.position.x, pos.y + camera.position.y)

func global_pos_to_coords(pos):
	return self.local_to_map(self.to_local(get_real_pos(pos)))

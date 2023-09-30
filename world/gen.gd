extends TileMap

@onready var camera = $Camera2D

var tile = preload("res://world/tile.tscn")
var tiles = {}
var regions = {}

func spawn_cell(coords, team):
	if tiles.has(coords):
		print("Error: cell already exists at " + str(coords))
		return
	var new_tile = tile.instantiate()
	new_tile.init_cell(coords, coords_to_pos(coords), Constants.TILE_GRASS, team)
	self.add_child(new_tile)
	tiles[coords] = new_tile

# Called when the node enters the scene tree for the first time.
func _ready():
	tile_water();
	const n_tiles_max = Constants.WORLD_BOUNDS.x * Constants.WORLD_BOUNDS.y * 4
	const n_tiles_target = round(n_tiles_max * 0.25);
	spawn_cell(Constants.WORLD_CENTER, Constants.NO_TEAM);
	var used_cells_coords = self.tiles.keys();
	while ((used_cells_coords.size() < n_tiles_target)):
		var cell_coords = used_cells_coords[randi() % used_cells_coords.size()]
		var neighbor = self.get_neighbor_cell(cell_coords, Utils.choose_random_direction());
		if (Utils.is_in_world(neighbor) and not self.tiles.has(neighbor)):
			spawn_cell(neighbor, Constants.NO_TEAM)
			used_cells_coords = self.tiles.keys();
	set_team_start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func get_real_pos(pos):
	return Vector2(pos.x + camera.position.x, pos.y + camera.position.y)

func global_pos_to_coords(pos):
	return self.local_to_map(self.to_local(get_real_pos(pos)))

func coords_to_pos(coords):
	return self.map_to_local(coords)

func tile_water():
	for i in range(-Constants.WORLD_CAMERA_BOUNDS.x, Constants.WORLD_CAMERA_BOUNDS.x):
		for j in range(-Constants.WORLD_CAMERA_BOUNDS.y, Constants.WORLD_CAMERA_BOUNDS.y):
			self.set_cell(0, Vector2i(Constants.WORLD_CENTER.x + i, Constants.WORLD_CENTER.y + j), 0, Vector2i(0, 0), 0)

func set_team_start():
	var sorted_tiles = tiles.values()
	sorted_tiles.sort_custom(func(a, b): return count_neighbors(a) > count_neighbors(b))
	sorted_tiles[0].set_team(1)
	sorted_tiles[1].set_team(2)
	sorted_tiles[2].set_team(3)
	sorted_tiles[0].set_borders(Constants.FULL_BORDERS)
	sorted_tiles[1].set_borders(Constants.FULL_BORDERS)
	sorted_tiles[2].set_borders(Constants.FULL_BORDERS)
		
func count_neighbors(cell):
	var total = 0;
	for neighbor in self.get_surrounding_cells(cell.coords):
		if (self.get_cell_source_id(1, neighbor) == -1):
			total += 1
	return total

func delete_cell(coords: Vector2i):
	self.tiles[coords].queue_free()
	self.tiles.erase(coords)

func pick_random_tile():
	var keys = self.tiles.keys()
	return self.tiles[keys[randi() % keys.size()]]

func generate_disaster():
	# only sinking tiles for now
	delete_cell(pick_random_tile().coords)
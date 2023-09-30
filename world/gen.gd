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
	pass

func init_world():
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

func sort_most_neighbors():
	var sorted_tiles = self.tiles.values()
	sorted_tiles.sort_custom(func(a, b): return count_neighbors(a) > count_neighbors(b))
	return sorted_tiles

func sort_least_neighbors():
	var sorted_tiles = self.tiles.values()
	sorted_tiles.sort_custom(func(a, b): return count_neighbors(a) < count_neighbors(b))
	return sorted_tiles

func add_team(team_id : int):
	var least_neighbors = self.sort_least_neighbors()
	## find first tile with no team
	var tile_found = null
	for tile_val in least_neighbors:
		if (tile_val.team == Constants.NO_TEAM):
			tile_found = tile_val
			break
	
	tile_found.set_team(team_id)
	tile_found.set_borders(Constants.FULL_BORDERS)
		
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

func move_units(tile_from : Vector2i, tile_to: Vector2i):
	if not self.tiles.has(tile_from):
		print("Error: invalid tile coordinates", tile_from)
		return
	if not self.tiles.has(tile_to):
		print("Error: invalid tile coordinates", tile_to)
		return
	if self.tiles[tile_from].units <= 1:
		print("Error: not enough units to move:", tiles[tile_from].units)
	var moved_units = tiles[tile_from].units - 1
	if tiles[tile_from].team == tiles[tile_to].team:
		tiles[tile_from].set_units(1)
		tiles[tile_to].set_units( tiles[tile_to].units + moved_units)
	else:
		tiles[tile_from].set_units(1)
		if tiles[tile_to].units >= moved_units:
			tiles[tile_to].set_units(tiles[tile_to].units - moved_units)
		else:
			tiles[tile_to].set_units(moved_units - tiles[tile_to].units)
			tiles[tile_to].team = tiles[tile_from].team

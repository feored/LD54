extends TileMap

@onready var camera = $Camera2D
@onready var coordsLabel = $"%Coordinates"
@onready var unitsLabel = $"%Units"
@onready var teamLabel = $"%TeamLabel"

var clicked_tile = null
var tile = preload("res://world/tile.tscn")
var tiles = {}

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
	const n_tiles_min = round(n_tiles_max * 0.15);
	const n_tiles_target = int(round(n_tiles_max * 0.66));
	spawn_cell(Constants.WORLD_CENTER, Constants.NO_TEAM);
	var used_cells_coords = self.tiles.keys();
	while ((used_cells_coords.size() < n_tiles_min)): # || (randi() % n_tiles_max) < n_tiles_target):
		var cell_coords = used_cells_coords[randi() % used_cells_coords.size()]
		var neighbor = self.get_neighbor_cell(cell_coords, choose_random_direction());
		if (is_in_world(neighbor) && self.get_cell_source_id(1, neighbor) == -1):
			spawn_cell(neighbor, Constants.NO_TEAM)
			used_cells_coords = self.tiles.keys();
	set_team_start()
	spawn_cell(Constants.WORLD_CENTER, 0);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# var new_tile = tile.new(global_pos_to_coords(event.position), 1, 0)
			self.set_cell(1, global_pos_to_coords(event.position), -1, Vector2i(0,0), 0);
			# self.update_cell(new_tile)


func get_real_pos(pos):
	return Vector2(pos.x + camera.position.x, pos.y + camera.position.y)

func global_pos_to_coords(pos):
	return self.local_to_map(self.to_local(get_real_pos(pos)))

func coords_to_pos(coords):
	return self.map_to_local(coords)

func choose_random_direction():
	var rand = randi() % 6;
	if (rand == 0):
		return TileSet.CELL_NEIGHBOR_RIGHT_SIDE;
	if (rand == 1):
		return TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE;
	if (rand == 2):
		return TileSet.CELL_NEIGHBOR_LEFT_SIDE;
	if (rand == 3):
		return TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE;
	if (rand == 4):
		return TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE;
	if (rand == 5):
		return TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE;

func is_in_world(cell):
	return cell.x > -Constants.WORLD_BOUNDS.x && cell.x < Constants.WORLD_BOUNDS.x && cell.y > -Constants.WORLD_BOUNDS.y && cell.y < Constants.WORLD_BOUNDS.y

func tile_water():
	for i in range(-Constants.WORLD_BOUNDS.x, Constants.WORLD_BOUNDS.x):
		for j in range(-Constants.WORLD_BOUNDS.y, Constants.WORLD_BOUNDS.y):
			self.set_cell(0, Vector2i(Constants.WORLD_CENTER.x + i, Constants.WORLD_CENTER.y + j), 0, Vector2i(0, 0), 0)

func set_team_start():
	var sorted_tiles = tiles.values();
	sorted_tiles.sort_custom(func(a, b): return count_neighbors(a) > count_neighbors(b))
	sorted_tiles[0].set_team(1)
	sorted_tiles[1].set_team(2)
	sorted_tiles[2].set_team(3)
		
func count_neighbors(cell):
	var total = 0;
	for neighbor in self.get_surrounding_cells(cell.coords):
		if (self.get_cell_source_id(1, neighbor) == -1):
			total += 1;
	return total;

extends TileMap


@onready var camera = $"%MainCamera"
@onready var regionLabelsParent = $"%RegionLabels"
@onready var world = $"%World"


var regionLabelPrefab = preload("res://world/region_label.tscn")
var tile = preload("res://world/tile.tscn")


var tiles = {}
var regions = {}


func spawn_cell(coords, team):
	if tiles.has(coords):
		print("Error: cell already exists at " + str(coords))
		return
	var new_tile = tile.instantiate()
	new_tile.init_cell(coords, self.coords_to_pos(coords), Constants.TILE_GRASS, team)
	self.add_child(new_tile)
	tiles[coords] = new_tile



func init_world():
	print("World center", Constants.WORLD_CENTER)
	tile_water()
	generate_island()


func generate_island():
	const n_tiles_max = Constants.WORLD_BOUNDS.x * Constants.WORLD_BOUNDS.y * 4
	const n_tiles_target = round(n_tiles_max * 0.4)
	spawn_cell(Constants.WORLD_CENTER, Constants.NO_TEAM)
	var used_cells_coords = self.tiles.keys()
	while ((used_cells_coords.size() < n_tiles_target)):
		var cell_coords = used_cells_coords[randi() % used_cells_coords.size()]
		var neighbor = self.get_neighbor_cell(cell_coords, Utils.choose_random_direction())
		if (Utils.is_in_world(neighbor) and not self.tiles.has(neighbor)):
			spawn_cell(neighbor, Constants.NO_TEAM)
			used_cells_coords = self.tiles.keys()
	generate_regions()
	apply_borders()

func generate_regions():
	var current_region = 0
	var tiles_shuffled = self.tiles.keys()
	tiles_shuffled.shuffle()
	
	while tiles_shuffled.size() > 0:
		var start = tiles_shuffled.pop_back()
		regions[current_region] = create_region(current_region)
		add_tile_to_region(start, current_region)
		for i in range(Constants.REGION_MAX_SIZE):
			var random_in_region = regions[current_region].random_in_region()
			var neighbor_dirs = Constants.NEIGHBORS.duplicate()
			neighbor_dirs.shuffle();
			var expanded = false
			for neighbor_dir in neighbor_dirs:
				var neighbor = self.get_neighbor_cell(random_in_region, neighbor_dir)
				if (self.tiles.has(neighbor) and self.tiles[neighbor].region == Constants.NO_REGION):
					tiles_shuffled.erase(neighbor)
					add_tile_to_region(neighbor, current_region)
					expanded = true
					break
			if not expanded:
				break
		region_update_label(regions[current_region])
		current_region += 1

func add_tile_to_region(tile_coords, region):
	self.tiles[tile_coords].set_region(region)
	regions[region].add_tile(tile_coords, self.tiles[tile_coords])

func create_region(id: int):
	var region = Region.new(id)
	var regionLabel = regionLabelPrefab.instantiate()
	regionLabelsParent.add_child(regionLabel)	
	region.label = regionLabel
	return region

func apply_borders():
	for tile_coords in self.tiles:
		var tile_obj = self.tiles[tile_coords]
		for neighbor_direction in Constants.NEIGHBORS:
			var neighbor = self.get_neighbor_cell(tile_coords, neighbor_direction)
			if (self.tiles.has(neighbor)):
				if(tile_obj.region != self.tiles[neighbor].region):
					tile_obj.set_single_border(neighbor_direction, true)
			else:
				tile_obj.set_single_border(neighbor_direction, true)


func region_update_label(region: Region):
	region.label.position = self.coords_to_pos(region.center_tile()) - Vector2(30, 20)/2 ## size of the label
	region.update_display()

	
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
	#var least_neighbors = self.sort_least_neighbors()
	## find first tile with no team

	# var tile_found = null
	# for tile_val in least_neighbors:
	# 	if (tile_val.team == Constants.NO_TEAM):
	# 		tile_found = tile_val
	# 		break
	regions[team_id].set_team(team_id)
	regions[team_id].set_team(team_id)
		
func count_neighbors(cell: Tile):
	var total = 0;
	for neighbor in self.get_surrounding_cells(cell.coords):
		if (self.tiles.has(neighbor)):
			total += 1
	return total

func delete_cell(coords: Vector2i):
	self.regions[self.tiles[coords].region].tiles.erase(coords)
	self.tiles[coords].queue_free()
	self.tiles.erase(coords)

func recalculate_region(region: int):
	var region_tiles = self.regions[region].tiles.keys()
	if (region_tiles.size() == 0):
		self.regions[region].delete()
		self.regions.erase(region)
		return
	self.regions[region].reset_tiles()
	for tile_coords in region_tiles:
		self.tiles[tile_coords].set_region(Constants.NO_REGION)
	var region_to_expand = region
	while (region_tiles.size() > 0):
		expand_single_region_from_coords(region_to_expand, region_tiles)
		if (region_tiles.size() > 0):
			region_to_expand = self.regions.keys().max() + 1
			self.regions[region_to_expand] = create_region(region_to_expand)
	self.apply_borders()

func expand_single_region_from_coords(region: int, region_tiles: Array):
	var new_center = region_tiles.pop_back()
	add_tile_to_region(new_center, region)
	var added = true
	while added:
		added = false
		for tile_coords in region_tiles:
			for neighbor in self.get_surrounding_cells(tile_coords):
				if (self.tiles.has(neighbor) and self.tiles[neighbor].region == region):
					add_tile_to_region(tile_coords, region)
					added = true
					region_tiles.erase(tile_coords)
					break
			if added:
				break
	region_update_label(self.regions[region])
	
func generate_disaster():
	# only sinking tiles for now
	var deleted_cell = Utils.pick_tile_to_sink(self.tiles.values())
	print("Deleting cell at", deleted_cell.coords, " with distance ", Utils.distance_from_center(deleted_cell))
	var deleted_cell_region = deleted_cell.region
	delete_cell(deleted_cell.coords)
	recalculate_region(deleted_cell_region)

func move_units(region_from : int, region_to: int):
	if not self.regions.has(region_from):
		print("Error: invalid region trying to move", region_from)
		return
	if not self.regions.has(region_to):
		print("Error: invalid region trying to move to", region_to)
		return
	if self.regions[region_from].units <= 1:
		print("Error: not enough units to move:", regions[region_from].units)
		return
	if not region_to in self.adjacent_regions(region_from):
		print("Error: regions are not adjacent")
		return
	var moved_units = regions[region_from].units - 1
	if regions[region_from].team == regions[region_to].team:
		regions[region_from].set_units(1)
		regions[region_to].set_units( regions[region_to].units + moved_units)
	else:
		regions[region_from].set_units(1)
		if regions[region_to].units >= moved_units:
			regions[region_to].set_units(regions[region_to].units - moved_units)
		else:
			regions[region_to].set_units(moved_units - regions[region_to].units)
			regions[region_to].set_team(regions[region_from].team)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func get_real_pos(pos):
	return Vector2(pos.x + camera.position.x, pos.y + camera.position.y)

func global_pos_to_coords(pos):
	return self.local_to_map(self.to_local(get_real_pos(pos)))

func coords_to_pos(coords):
	return self.map_to_local(coords)

func adjacent_regions(region_id : int):
	var adjacent = []
	for t in regions[region_id].tiles:
		for neighbor in self.get_surrounding_cells(t):
			if self.tiles.has(neighbor):
				var neighbor_region = self.tiles[neighbor].region
				if not adjacent.has(neighbor_region):
					adjacent.append(neighbor_region)
	return adjacent

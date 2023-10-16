extends TileMap


var messenger = null
@onready var camera = $"%MainCamera"
@onready var regionLabelsParent = $"%RegionLabels"

var regionLabelPrefab = preload("res://world/regions/region_label.tscn")
var tile = preload("res://world/tiles/tile.tscn")

var tiles = {}
var regions = {}
var regions_used = []


func spawn_cell(coords, team, borders = Constants.NO_BORDERS.duplicate()):
	if tiles.has(coords):
		print("Error: cell already exists at " + str(coords))
		return
	var new_tile = tile.instantiate()
	var delete = Callable(self, "delete_cell_memory")
	new_tile.init_cell(coords, self.coords_to_pos(coords), team, borders, delete)
	self.add_child(new_tile)
	tiles[coords] = new_tile

func remove_cell(coords):
	var region = self.tiles[coords].region
	if region != Constants.NULL_REGION:
		self.regions[region].tiles.erase(coords)
	self.tiles[coords].delete() # queue_free?
	self.tiles.erase(coords)
	if region != Constants.NULL_REGION:
		recalculate_region(region)

func init(messengerCallable):
	self.messenger = messengerCallable
	tile_water()


func clear_regions_mapeditor():
	for region in self.regions:
		self.regions[region].delete_no_tiles()
	self.regions.clear()
	self.regions_used.clear()
	for tile_obj in self.tiles.values():
		tile_obj.region = Constants.NULL_REGION
	self.apply_borders()

func clear_island():
	for tile_obj in self.tiles.values():
		tile_obj.queue_free()
	self.tiles.clear()
	for region in self.regions:
		self.regions[region].delete()
	self.regions.clear()
	self.regions_used.clear()


func generate_island(island_size = Constants.ISLAND_SIZE_DEFAULT):
	const n_tiles_max = Constants.WORLD_BOUNDS.x * Constants.WORLD_BOUNDS.y * 4
	var n_tiles_target = round(n_tiles_max * island_size)
	spawn_cell(Constants.WORLD_CENTER, Constants.NULL_TEAM)
	var used_cells_coords = self.tiles.keys()
	while ((used_cells_coords.size() < n_tiles_target)):
		var cell_coords = used_cells_coords[randi() % used_cells_coords.size()]
		var neighbor = self.get_neighbor_cell(cell_coords, Utils.choose_random_direction())
		if (Utils.is_in_world(neighbor) and not self.tiles.has(neighbor)):
			spawn_cell(neighbor, Constants.NULL_TEAM)
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
				if (self.tiles.has(neighbor) and self.tiles[neighbor].region == Constants.NULL_REGION):
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

func create_region(id: int) -> Region:
	var region = Region.new(id)
	var regionLabel = regionLabelPrefab.instantiate()
	self.add_child(region)
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
	var foundRegion = false
	while not foundRegion:
		var random_region = regions[Utils.rng.randi() % self.regions.size()]
		if random_region.team == Constants.NULL_TEAM:
			random_region.set_team(team_id)
			foundRegion = true
		
func count_neighbors(cell: Tile):
	var total = 0;
	for neighbor in self.get_surrounding_cells(cell.coords):
		if (self.tiles.has(neighbor)):
			total += 1
	return total

func get_tile_group_center_position(coords_group: Array):
	var total = Vector2(0, 0)
	for c in coords_group:
		total += self.coords_to_pos(c)
	return total / coords_group.size()

func delete_cell(coords_array: Array, action = null):
	if action != null:
		var team_name = Constants.TEAM_NAMES[action.team]
		if action.team == self.tiles[coords_array[0]].team:
			self.messenger.call("%s sacrifices their own land to curry favor from the gods..." % team_name)
		else:
			var enemy_team_name = Constants.TEAM_NAMES[self.tiles[coords_array[0]].team]
			self.messenger.call("%s begs the gods to strike down the land of %s..." % [team_name, enemy_team_name])
	else:
		self.messenger.call("A patch of land sinks somewhere...")
	await self.camera.move_smoothed(self.coords_to_pos(coords_array[0]), 5)
	var delete_finished = 0
	for coords in coords_array:
		self.tiles[coords].delete()
	var check_all_deleted = func():
		for coords in coords_array:
			if self.tiles.has(coords):
				return false
		return true
	while not check_all_deleted.call():
		await Utils.wait(0.1)
		
	

func delete_cell_memory(coords : Vector2i):
	if not self.tiles.has(coords):
		print("Error: tiles does not have coords: ", coords)
		return
	self.regions[self.tiles[coords].region].tiles.erase(coords)
	self.tiles.erase(coords)

	

func recalculate_region(region: int):
	if (self.regions[region].tiles.size() == 0):
		var r = self.regions[region]
		self.regions.erase(region)
		r.delete()
		return
	var region_tiles = self.regions[region].tiles.keys()
	self.regions[region].reset_tiles()
	for tile_coords in region_tiles:
		self.tiles[tile_coords].set_region(Constants.NULL_REGION)
	var region_to_expand = region
	while (region_tiles.size() > 0):
		expand_single_region_from_coords(region_to_expand, region_tiles)
		if (region_tiles.size() > 0):
			region_to_expand = self.regions.keys().max() + 1
			self.regions[region_to_expand] = create_region(region_to_expand)
	region_update_label(self.regions[region])
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

func sacrifice_tile(coords, action):
	var deleted_cell_region = self.tiles[coords].region
	await delete_cell([coords], action)
	recalculate_region(deleted_cell_region)

func sink_tiles(coords):
	var regions_impacted = []
	for coord in coords:
		regions_impacted.append(self.tiles[coord].region)
	await delete_cell(coords)
	for region in regions_impacted:
		if self.regions.has(region):
			recalculate_region(region)

func generate_disaster(global_turn):
	# only sinking tiles for now
	var n = self.tiles.size()
	var total_disasters = min(n, int(global_turn * n / 10.0))
	print("Total disasters: ", total_disasters)
	if (global_turn <= Constants.SINK_GRACE_PERIOD):
		total_disasters = 0
	var disasters_dealt = 0
	while disasters_dealt < total_disasters and self.tiles.size() > 1:
		var num_to_sink = min(total_disasters - disasters_dealt, total_disasters / 5)
		var cur_cell = Utils.pick_tile_to_sink(self.tiles.keys())
		var tiles_to_delete = [cur_cell]
		disasters_dealt += 1
		for i in range(1, num_to_sink):
			var neighbors = []
			for potential_neighbor in self.get_surrounding_cells(cur_cell):
				if self.tiles.has(potential_neighbor) and potential_neighbor not in tiles_to_delete:
					neighbors.append(potential_neighbor)
			if neighbors.size() < 1:
				break
			neighbors.shuffle()
			cur_cell = neighbors[0]
			tiles_to_delete.append(cur_cell)
			disasters_dealt += 1
		await sink_tiles(tiles_to_delete)
		await Utils.wait(Constants.TURN_TIME)

func move_units(region_from : int, region_to: int, team: int):
	var is_player = team == 1
	if not self.regions.has(region_from):
		print("Error: invalid region trying to move", region_from)
	if not self.regions.has(region_to):
		print("Error: invalid region trying to move to", region_to)
	if self.regions[region_from].units <= 1:
		print("Error: not enough units to move:", regions[region_from].units)
	if not region_to in self.adjacent_regions(region_from):
		print("Error: regions are not adjacent")

	# success
	var moved_units = regions[region_from].units - 1
	if not is_player:
		var team_name = Constants.TEAM_NAMES[team]
		if self.regions[region_from].team == self.regions[region_to].team:
			self.messenger.call("%s is moving %s troops to a friendly neighboring region..." % [team_name, moved_units])
		else:
			var enemy_team_name = Constants.TEAM_NAMES[self.regions[region_to].team] 
			self.messenger.call("%s is attacking a neighboring %s region with %s troops!" % [team_name, enemy_team_name, moved_units])
		await self.camera.move_smoothed(self.coords_to_pos(self.regions[region_from].center_tile()), 5)
	
	if regions[region_from].team == regions[region_to].team:
		regions[region_from].set_units(1)
		regions[region_to].set_units( regions[region_to].units + moved_units)
	else:
		regions[region_from].set_units(1)
		if regions[region_to].units >= moved_units:
			regions[region_to].set_units(regions[region_to].units - moved_units)
			self.regions[region_from].set_used(true)
			self.regions_used.append(region_from)
			return
		else:
			regions[region_to].set_units(moved_units - regions[region_to].units)
			regions[region_to].set_team(regions[region_from].team)
	self.regions[region_from].set_used(true)
	# self.regions[region_to].set_used(true)
	self.regions_used.append(region_from)
	# self.regions_used.append(region_to)
	if not is_player:
		await Utils.wait(Constants.TURN_TIME)

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
				if neighbor_region != region_id and not adjacent.has(neighbor_region):
					adjacent.append(neighbor_region)
	return adjacent

func clear_regions_used():
	for region in regions_used:
		regions[region].set_used(false)
	regions_used.clear()


func reset_regions_team():
	for region in self.regions:
		self.regions[region].set_team(Constants.NULL_TEAM)



func load_tiles(new_tiles):
	for coords_string in new_tiles:
		var parsed_tile = new_tiles[coords_string]
		var coords = str_to_var(coords_string)
		var borders = {}
		for border_str in parsed_tile.borders:
			borders[int(border_str)] = parsed_tile.borders[border_str]
		self.spawn_cell(coords, parsed_tile.team, borders)

func load_regions(new_regions):
	for region_id_str in new_regions:
		var saved_region = new_regions[region_id_str]
		var region_id = int(region_id_str)
		var region = self.create_region(region_id)
		for coords_str in saved_region.tiles:
			var coords = str_to_var(coords_str)
			region.add_tile(coords, self.tiles[coords])
		region.set_team(saved_region.team)
		region.set_units(saved_region.units)
		self.regions[region_id] = region
		self.region_update_label(region)
		if region.team != Constants.NULL_TEAM:
			region.generate_units()
			

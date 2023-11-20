extends TileMap

signal world_ready
var messenger = null
@onready var camera = $"%MainCamera"

var tiles = {}
var regions = {}

func init(messengerCallable):
	self.messenger = messengerCallable
	tile_water()

func spawn_region(id: int, from_save: Dictionary = {}) -> Region:
	var region = Region.new(id)
	region.coords_to_pos = Callable(self, "coords_to_pos")
	region.tile_deleted.connect(func(coords): self.tiles.erase(coords))
	region.region_deleted.connect(Callable(self, "erase_region"))
	region.tile_added.connect(func(tile): self.tiles[tile.data.coords] = tile)
	if from_save.size() > 0:
		region.init_from_save(from_save)
	self.add_child(region)
	return region

func erase_region(id: int):
	for tile in self.regions[id].data.tiles:
		self.tiles.erase(tile)
	self.regions.erase(id)

func clear_island():
	for region in self.regions.values():
		region.delete()
	self.regions.clear()

func get_next_empty_cell_in_direction(next_position, direction):
	if self.tiles.keys().has(next_position):
		return get_next_empty_cell_in_direction(self.get_neighbor_cell(next_position, direction), direction)
	else:
		return next_position

func generate_island(island_size = Constants.ISLAND_SIZE_DEFAULT, instant = true):
	await self.generate_tiles(island_size, instant)
	if not instant:
		await Utils.wait(0.25)
	await self.generate_regions()

func generate_tiles(island_size, instant):
	const n_tiles_max = Constants.WORLD_BOUNDS.x * Constants.WORLD_BOUNDS.y * 4
	var n_tiles_target = round(n_tiles_max * island_size)
	var current_cell = Constants.WORLD_CENTER
	var new_region = region_new_id()
	self.regions[new_region] = spawn_region(new_region)
	self.tiles[Constants.WORLD_CENTER] = self.regions[new_region].spawn_cell(Constants.WORLD_CENTER, Constants.NULL_TEAM)
	var created_tiles = [Constants.WORLD_CENTER]
	while (created_tiles.size() < n_tiles_target):
		var movement = (Utils.rng.randi() % 3) == 0
		var available_directions = []
		for dir in Constants.NEIGHBORS:
			available_directions.append(get_next_empty_cell_in_direction(current_cell, dir))
		available_directions = available_directions.filter(func(x): return Utils.is_in_world(x))
		var next_empty = available_directions[Utils.rng.randi() % available_directions.size()]
		if movement:
			current_cell = next_empty
		self.tiles[next_empty] = self.regions[new_region].spawn_cell(next_empty, Constants.NULL_TEAM)
		created_tiles.append(next_empty)
		if not instant:
			await Utils.wait(0.025)
	self.regions[new_region].update()
	
func generate_regions():
	var current_region = region_new_id()
	var tiles_shuffled = self.tiles.keys()
	tiles_shuffled.shuffle()
	while tiles_shuffled.size() > 0:
		var start = tiles_shuffled.pop_back()
		regions[current_region] = spawn_region(current_region)
		self.regions[self.tiles[start].data.region].remove_tile(start, true)
		regions[current_region].add_tile(self.tiles[start])
		for i in range(Constants.REGION_MAX_SIZE):
			var random_in_region = regions[current_region].random_in_region()
			var neighbor_dirs = Constants.NEIGHBORS.duplicate()
			neighbor_dirs.shuffle();
			var expanded = false
			for neighbor_dir in neighbor_dirs:
				var neighbor = self.get_neighbor_cell(random_in_region, neighbor_dir)
				if (tiles.has(neighbor) and tiles_shuffled.has(neighbor)):
					tiles_shuffled.erase(neighbor)
					self.regions[self.tiles[neighbor].data.region].remove_tile(neighbor, true)
					regions[current_region].add_tile(self.tiles[neighbor])
					expanded = true
					break
			if not expanded:
				break
		current_region = region_new_id()
	for region in self.regions.values():
		region.update()
	world_ready.emit()


func tile_water():
	for i in range(-Constants.WORLD_CAMERA_BOUNDS.x, Constants.WORLD_CAMERA_BOUNDS.x):
		for j in range(-Constants.WORLD_CAMERA_BOUNDS.y, Constants.WORLD_CAMERA_BOUNDS.y):
			self.set_cell(0, Vector2i(Constants.WORLD_CENTER.x + i, Constants.WORLD_CENTER.y + j), 0, Vector2i(0, 0), 0)

func sort_most_neighbors():
	var sorted_tiles = self.tiles.keys()
	sorted_tiles.sort_custom(func(a, b): return count_neighbors(a, sorted_tiles) > count_neighbors(b, sorted_tiles))
	return sorted_tiles

func sort_least_neighbors():
	var sorted_tiles = self.tiles.keys()
	sorted_tiles.sort_custom(func(a, b): return count_neighbors(a, sorted_tiles) < count_neighbors(b, sorted_tiles))
	return sorted_tiles

func add_team(team_id : int):
	##REDO
	var foundRegion = false
	while not foundRegion:
		var random_region = self.regions.values()[Utils.rng.randi() % self.regions.size()]
		if random_region.data.team == Constants.NULL_TEAM:
			random_region.set_team(team_id)
			foundRegion = true
		
func count_neighbors(cell: Tile, all_tiles):
	var total = 0;
	for neighbor in self.get_surrounding_cells(cell.coords):
		if (all_tiles.has(neighbor)):
			total += 1
	return total

func get_tile_obj(coords):
	return self.regions[self.tiles[coords].data.region].tile_objs[coords]

func deleted_tile(coords):
	if self.tiles.has(coords):
		return false
	return true

func sink_tiles(coords_array: Array):
	self.messenger.call("A patch of land sinks somewhere...")
	await self.camera.move_smoothed(self.coords_to_pos(coords_array[0]), 5)
	for coords in coords_array:
		self.tiles[coords].sink()
	var check_all_deleted = func(coords):
		for c in coords:
			if self.tiles.has(coords):
				return false
		return true
	while not check_all_deleted.call(coords_array):
		await Utils.wait(0.1)
		
func region_new_id():
	if self.regions.size() == 0:
		return 0
	return self.regions.keys().max() + 1

func recalculate_region(region: int):
	## TODO remove region from tile.gd
	if (self.regions[region].data.tiles.size() == 0):
		var r = self.regions[region]
		self.regions.erase(region)
		r.delete()
		return
	var region_tiles = self.regions[region].tile_objs.keys()
	self.regions[region].clear()
	for tile_coords in region_tiles:
		self.tiles[tile_coords].set_region(Constants.NULL_REGION)
	var region_to_expand = region
	while (region_tiles.size() > 0):
		expand_single_region_from_coords(region_to_expand, region_tiles)
		if (region_tiles.size() > 0):
			region_to_expand = region_new_id()
			self.regions[region_to_expand] = spawn_region(region_to_expand)


func expand_single_region_from_coords(region: int, region_tiles: Array):
	var new_center = region_tiles.pop_back()
	self.regions[region].add_tile(new_center)
	var added = true
	while added:
		added = false
		for tile_obj in region_tiles:
			for neighbor in self.get_surrounding_cells(tile_obj):
				if (self.tiles.has(neighbor) and self.tiles[neighbor].data.region == region):
					self.regions[region].add_tile(tile_obj)
					added = true
					region_tiles.erase(tile_obj)
					break
			if added:
				break
	self.regions[region].update()

func mark_tiles(global_turn):
	# only sinking tiles for now
	var n = self.tiles.size()
	var tiles_to_mark = int(1 + n/(Utils.rng.randf_range(15.0, 30.0)))
	if (global_turn < Constants.SINK_GRACE_PERIOD):
		tiles_to_mark = 0
	var cur_cell = Utils.pick_tile_to_sink(self.tiles.keys())
	for i in range(tiles_to_mark):
		var neighbors = self.get_surrounding_cells(cur_cell).filter(func(x): return self.tiles.has(x) and not self.tiles[x].data.marked)
		if Utils.rng.randi() % 5 == 0 or neighbors.size() < 1:
			cur_cell = Utils.pick_tile_to_sink(self.tiles.keys(), i)
		else:
			cur_cell = neighbors[randi() % neighbors.size()]
		self.tiles[cur_cell].mark()
	if tiles_to_mark > 0:
		self.messenger.call("Neptune has marked those who are destined to perish.")
		await Utils.wait(Settings.turn_time)

func sink_marked():
	var marked_coords = self.tiles.values().filter(func(x): return x.data.marked).map(func(x): return x.data.coords)
	if marked_coords.size() > 0:
		await sink_tiles(marked_coords)
		await Utils.wait(Settings.turn_time)

func move_units(region_from : int, region_to: int, team: int, simulated = false):
	var is_player = team == 1
	if not self.regions.has(region_from):
		print("Error: invalid region trying to move", region_from)
	if not self.regions.has(region_to):
		print("Error: invalid region trying to move to", region_to)
	if self.regions[region_from].data.units <= 1:
		print("Error: not enough units to move:", regions[region_from].units)
	if not region_to in self.adjacent_regions(region_from):
		print("Error: regions are not adjacent")

	# success
	if not is_player and not simulated:
		await self.camera.move_smoothed(self.coords_to_pos(self.regions[region_from].center_tile()), 5)

	var moved_units = regions[region_from].data.units - 1 #max(1, regions[region_from].units/2)
	regions[region_from].set_units(regions[region_from].data.units - moved_units)
	self.regions[region_from].set_used(true)

	if regions[region_from].data.team == regions[region_to].data.team:
		regions[region_to].reinforce(moved_units)
	else:
		regions[region_to].attack(moved_units, team)
			
	if not is_player and not simulated:
		await Utils.wait(Settings.turn_time)

func get_tile_region(coords):
	return self.regions[self.tiles[coords].data.region]

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
	var all = self.tiles
	for t in regions[region_id].data.tiles:
		for neighbor in self.get_surrounding_cells(t):
			if all.has(neighbor):
				var neighbor_region = all[neighbor].data.region
				if neighbor_region != region_id and not adjacent.has(neighbor_region):
					adjacent.append(neighbor_region)
	return adjacent

func clear_regions_used():
	for region in regions:
		regions[region].set_used(false)

func reset_regions_team():
	for region in self.regions:
		self.regions[region].set_team(Constants.NULL_TEAM)

func load_regions(new_regions):
	for region in new_regions:
		self.regions[region.id] = self.spawn_region(region.id, region)
		if region.team != Constants.NULL_TEAM:
			print("generated")
			self.regions[region.id].generate_units()
		self.regions[region.id].update()

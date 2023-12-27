extends TileMap

signal world_ready
var messenger = null
@onready var camera = $"%MainCamera"

var tiles = {}
var regions = {}

func init(messengerCallable):
	self.messenger = messengerCallable
	tile_water()

func get_tiles():
	var total = []
	for region in self.regions.values():
		for t in region.data.tiles:
			total.append(t)
	return total

func spawn_region(id: int, from_save: Dictionary = {}):
	var region = Region.new(id)
	region.coords_to_pos = Callable(self, "coords_to_pos")
	region.tile_deleted.connect(Callable(self, "on_tile_deleted"))
	region.region_deleted.connect(func(id): self.regions.erase(id))
	region.tile_added.connect(func(tile): self.tiles[tile.data.coords] = tile)
	if from_save.size() > 0:
		region.init_from_save(from_save)
	self.add_child(region)
	self.regions[id] = region

func on_tile_deleted(coords):
	self.tiles.erase(coords)

func clear_island():
	for region in self.regions.values():
		region.delete()
	self.regions.clear()
	self.tiles.clear()

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
	spawn_region(new_region)
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
		spawn_region(current_region)
		self.regions[self.tiles[start].data.region].remove_tile(start, true, false)
		regions[current_region].add_tile(self.tiles[start])
		for i in range(Constants.REGION_MAX_SIZE):
			var random_in_region = regions[current_region].random_in_region()
			var neighbor_dirs = Constants.NEIGHBORS.duplicate()
			neighbor_dirs.shuffle()
			var expanded = false
			for neighbor_dir in neighbor_dirs:
				var neighbor = self.get_neighbor_cell(random_in_region, neighbor_dir)
				if (tiles.has(neighbor) and tiles_shuffled.has(neighbor)):
					tiles_shuffled.erase(neighbor)
					self.regions[self.tiles[neighbor].data.region].remove_tile(neighbor, true, false)
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

func sink_tiles(coords_array: Array):
	var affected_regions = []
	for coords in coords_array:
		var region = self.tiles[coords].data.region
		if not affected_regions.has(region):
			affected_regions.append(region)
	self.messenger.call("A patch of land sinks somewhere...")
	await self.camera.move_smoothed(self.coords_to_pos(coords_array[0]), 5)
	for coords in coords_array:
		self.tiles[coords].sink()
	
func region_new_id():
	if self.regions.size() == 0:
		return 0
	return self.regions.keys().max() + 1

func recalculate_region(region: int):
	if not self.regions.has(region):
		print("Error: invalid region trying to recalculate", region)
		return
	var region_tiles = self.regions[region].tile_objs.values().map(func(x): return x.data)
	var region_tile_coords = region_tiles.map(func(x): return x.coords)
	var tilesets = get_contiguous_tilesets(region_tile_coords)
	if tilesets.size() == 1:
		self.regions[region].update()
		return ## all contiguous
	var region_data = self.regions[region].data
	self.regions[region].clear()
	self.regions[region].delete()
	for tileset in tilesets:
		var new_region = region_new_id()
		spawn_region(new_region)
		for tile in tileset:
			self.regions[new_region].add_tile(self.tiles[tile], true)
		self.regions[new_region].set_team(region_data.team)
		self.regions[new_region].set_used(region_data.is_used)
		self.regions[new_region].set_units(region_data.units/len(tilesets))
		self.regions[new_region].update()

func get_contiguous_tilesets(tile_array: Array):
	var tilesets = []
	while tile_array.size() > 0:
		var tileset = [tile_array.pop_back()]
		var parsed = true
		while parsed:
			parsed = false
			for t in tileset:
				var neighbors = self.get_surrounding_cells(t)
				for neighbor in neighbors:
					if (tile_array.has(neighbor)) && (self.tiles.has(neighbor)):
						tileset.append(neighbor)
						tile_array.erase(neighbor)
						parsed = true
		tilesets.append(tileset)
	return tilesets


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
	var affected_regions = []
	for coords in marked_coords:
		var region = self.tiles[coords].data.region
		if not affected_regions.has(region):
			affected_regions.append(region)
	if marked_coords.size() > 0:
		await sink_tiles(marked_coords)
	var deleted = 0
	while deleted < marked_coords.size():
		deleted = 0
		await Utils.wait(0.1)
		for coords in marked_coords:
			if not self.tiles.has(coords):
				deleted += 1
	for region in affected_regions:
		self.recalculate_region(region)
	
	
	

func move_units(region_from : int, region_to: int, team: int):
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
	if not is_player:
		await self.camera.move_smoothed(self.coords_to_pos(self.regions[region_from].center_tile()), 5)

	var moved_units = regions[region_from].data.units - 1 #max(1, regions[region_from].units/2)
	regions[region_from].set_units(regions[region_from].data.units - moved_units)
	self.regions[region_from].set_used(true)

	if regions[region_from].data.team == regions[region_to].data.team:
		regions[region_to].reinforce(moved_units)
	else:
		regions[region_to].attack(moved_units, team)
			
	if not is_player:
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
		var region_id = int(region.id)
		self.spawn_region(region_id, region)
		if region.team != Constants.NULL_TEAM:
			self.regions[region_id].generate_units()
		self.regions[region_id].update()

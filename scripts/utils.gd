extends Node

var rng : RandomNumberGenerator

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()

func wait(time):
	await get_tree().create_timer(time).timeout

func team_to_layer(team):
	match team:
		1:
			return Constants.LAYER_P1
		2:
			return Constants.LAYER_P2
		3:
			return Constants.LAYER_P3
		_:
			return Constants.LAYER_GRASS

func choose_random_direction():
	match (randi() % 6):
		0:
			return TileSet.CELL_NEIGHBOR_RIGHT_SIDE;
		1:
			return TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE;
		2:
			return TileSet.CELL_NEIGHBOR_LEFT_SIDE;
		3:
			return TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE;
		4:
			return TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE;
		5:
			return TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE;

func is_in_world(cell):
	return cell.x > -Constants.WORLD_BOUNDS.x + Constants.WORLD_CENTER.x \
	and cell.x < Constants.WORLD_BOUNDS.x + Constants.WORLD_CENTER.x \
	and cell.y > -Constants.WORLD_BOUNDS.y + Constants.WORLD_CENTER.y \
	and cell.y < Constants.WORLD_BOUNDS.y + Constants.WORLD_CENTER.y

func pick_random_tile(tiles_dict):
	var keys = tiles_dict.keys()
	return tiles_dict[keys[randi() % keys.size()]]

func pick_tile_to_sink(tiles: Array):
	var count_neighbors_water = func(coords, tiles):
		var count = 0
		for neighbor in surrounding_cells(coords):
			if tiles.has(neighbor):
				count += 1
		return count
	if tiles.size() == 1:
		return tiles[0]
	tiles.sort_custom(func(a,b): return count_neighbors_water.call(a, tiles) < count_neighbors_water.call(b, tiles))
	var n = tiles.size()
	var total = n*(n-1)/2
	var random = [randi() % total, randi() % total].max()
	var running_total = 0
	for i in range(n):
		running_total += i
		if running_total >= random:
			return tiles[i]

func distance_from_center(tile):
	return abs(tile.coords.x - Constants.WORLD_CENTER.x) + \
		abs(tile.coords.y - Constants.WORLD_CENTER.y)

func surrounding_cells(coords):
	return [
		Vector2(coords.x, coords.y - 1),
		Vector2(coords.x, coords.y + 1),
		Vector2(coords.x - 1, coords.y),
		Vector2(coords.x + 1, coords.y),
		Vector2(coords.x - 1, coords.y - 1),
		Vector2(coords.x + 1, coords.y + 1),
	]

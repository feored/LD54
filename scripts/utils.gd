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

func pick_tile_to_sink(tiles: Array, offset: int = 0):
	if tiles.size() == 1:
		return tiles[0]
	tiles.sort_custom(func(a,b): return distance_from_center(a) > distance_from_center(b))
	return tiles[min(tiles.size() - 1, 0 + offset)]

func distance_from_center(coords):
	return abs(coords.x - Constants.WORLD_CENTER.x) + \
		abs(coords.y - Constants.WORLD_CENTER.y)

func surrounding_cells(coords):
	return [
		Vector2(coords.x, coords.y - 1),
		Vector2(coords.x, coords.y + 1),
		Vector2(coords.x - 1, coords.y),
		Vector2(coords.x + 1, coords.y),
		Vector2(coords.x - 1, coords.y - 1),
		Vector2(coords.x + 1, coords.y + 1),
	]

func to_map_object(tiles, regions, teams):
	return {
		"teams": teams,
		"tiles": tiles,
		"regions": regions
	}

func to_team_id(team_id):
	return team_id + 1

func distance(a, b):
	return abs(a.x - b.x) + abs(a.y - b.y)

func get_save_data(world, teams):
	var saved_tiles = []
	var saved_regions = []
	for coords in world.tiles:
		saved_tiles.append(world.tiles[coords].data.save())
	for region in world.regions:
		saved_regions.append(world.regions[region].data.save())
	return Utils.to_map_object(saved_tiles, saved_regions, teams.duplicate())
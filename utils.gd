extends Node


func _ready():
	randomize()

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

func pick_tile_to_sink(regions: Array):
	regions.sort_custom(func(a,b): return distance_from_center(a) - \
		distance_from_center(b) < 0)
	var n = regions.size()
	var total = n*(n-1)/2
	var random = [randi() % total, randi() % total].max()
	var running_total = 0
	for i in range(n):
		running_total += i
		if running_total >= random:
			return pick_random_tile(regions[i].tiles)

func distance_from_center(region):
	var center_tile = region.center_tile()
	var mod = 1
	if region.items.has(Constants.ItemEffectPhase.SINK):
		mod = region.items[Constants.ItemEffectPhase.SINK].modifier
	return mod * abs(center_tile.x - Constants.WORLD_CENTER.x) + \
		abs(center_tile.y - Constants.WORLD_CENTER.y)

func generate_random_item(region):
	var item_effect = Constants.ItemEffectPhase.values()[(randi() % (Constants.ItemEffectPhase.size() - 1)) + 1]
	region.items[item_effect] = create_item_with_effect(item_effect)
	print("Created Item with effect ", item_effect, " on region ", region.id)

func create_item_with_effect(item_effect):
	match item_effect:
		Constants.ItemEffectPhase.UNIT_GENERATION:
			return UnitBoost.new()
		Constants.ItemEffectPhase.SINK:
			return ProximityShrine.new()

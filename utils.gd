extends Node


func _ready():
	randomize()


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

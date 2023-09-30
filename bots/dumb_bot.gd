extends BaseBot
class_name DumbBot


func play_turn(world):
	## get random owned tile
	var owned_tiles = []
	for tile_coords in world.tiles:
		if world.tiles[tile_coords].team == team && world.tiles[tile_coords].units > 1:
			owned_tiles.append(tile_coords)
	owned_tiles.shuffle()
	for tile_coords in owned_tiles:
		for neighbor in world.get_surrounding_cells(tile_coords):
			if world.tiles.has(neighbor) and world.tiles[neighbor].team != team:
				return Action.new(self.team, Constants.Action.MOVE, tile_coords, neighbor)
	return Action.new(self.team, Constants.Action.NONE, Vector2i.ZERO, Vector2i.ZERO)

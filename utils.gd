extends Node


func coords_to_pos(coords: Vector2):
	var x = (coords.x * Constants.f0 + coords.y * Constants.f1) * Constants.TILE_SIZE
	var y = (coords.x * Constants.f2 + coords.y * Constants.f3) * Constants.TILE_SIZE
	return Vector2(x, y)

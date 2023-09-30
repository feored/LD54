extends Object

class_name Tile

var coords: Vector2i = Vector2i(0, 0)
var team = 0
var tile_type: int = Constants.TILE_GRASS
var units: int = 0


func _init(init_coords: Vector2, init_tile_type: int, init_team: int):
	self.coords = init_coords
	self.tile_type = init_tile_type
	self.team = init_team

extends Node

class_name Tile

var coords: Vector2i = Vector2i(0, 0)
var team = 0
var tile_type: int = Constants.TILE_GRASS
var units: int = 0
var init_position: Vector2 = Vector2(0, 0)


func init_cell(init_coords: Vector2, init_pos: Vector2, init_tile_type: int, init_team: int):
	self.coords = init_coords
	self.tile_type = init_tile_type
	self.team = init_team
	self.init_position = init_pos


func _ready():
	self.position = init_position
	self.modulate = Constants.TEAM_COLORS[team]

func update_cell():
	self.modulate = Constants.TEAM_COLORS[team]


func set_team(new_team: int):
	self.team = new_team
	self.update_cell()
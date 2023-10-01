extends Node

class_name Tile

@onready var border_objects = {
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE: $east,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE: $southwest,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE: $southeast,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE: $west,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE: $northwest,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE: $northeast
}

var coords: Vector2i = Vector2i(0, 0)
var team = 0
var tile_type: int = Constants.TILE_GRASS
var init_position: Vector2 = Vector2(0, 0)
var borders = Constants.NO_BORDERS.duplicate()
var region: int = Constants.NO_REGION

func init_cell(
	init_coords: Vector2,
	init_pos: Vector2,
	init_tile_type: int,
	init_team: int,
	init_borders: Dictionary = Constants.NO_BORDERS.duplicate()
):
	self.coords = init_coords
	self.tile_type = init_tile_type
	self.team = init_team
	self.init_position = init_pos
	self.borders = init_borders


func _ready():
	self.position = init_position
	self.update_cell()


func update_cell():
	for b in self.borders.keys():
		self.border_objects[b].modulate = Constants.TEAM_COLORS[team] if self.borders[b] else Color.hex(0x3aa25dff)
	var lighter_color = Color(Constants.TEAM_COLORS[self.team])
	lighter_color.a = Constants.BLENDING_MODULATE_ALPHA
	self.modulate = Color.hex(0xffffffff).blend(lighter_color)

func set_team(new_team: int):
	self.team = new_team
	self.update_cell()

func set_borders(new_borders: Dictionary):
	self.borders = new_borders.duplicate()
	self.update_cell()

func set_single_border(border_changed: int , value: bool):
	self.borders[border_changed] = value
	self.update_cell()

func set_region(new_region):
	self.region = new_region
	self.update_cell()

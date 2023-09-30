extends Node

class_name Tile

@onready var units_label = $Label
@onready var border = $border
@onready var border_objects = {
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE: $border/east,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE: $border/southwest,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE: $border/southeast,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE: $border/west,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE: $border/northwest,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE: $border/northeast
}

var coords: Vector2i = Vector2i(0, 0)
var team = 0
var tile_type: int = Constants.TILE_GRASS
var units: int = 0
var init_position: Vector2 = Vector2(0, 0)
var borders = Constants.NO_BORDERS.duplicate()

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
	self.border.modulate = Constants.TEAM_COLORS[team]
	for b in self.borders.keys():
		self.border_objects[b].visible = self.borders[b]
	units_label.set_text(str(self.units))
	self.self_modulate = Constants.TEAM_COLORS[self.team]

func set_team(new_team: int):
	self.team = new_team
	self.update_cell()

func set_borders(new_borders: Dictionary):
	self.borders = new_borders.duplicate()
	self.update_cell()

func set_single_border(border_changed: int , value: bool):
	self.borders[border_changed] = value
	self.update_cell()

func set_units(new_units):
	self.units = new_units
	self.update_cell()

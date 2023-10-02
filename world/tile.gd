extends Node

class_name Tile

@onready var animation_player = $AnimationPlayer
@onready var border_objects = {
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE: $east,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE: $southwest,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE: $southeast,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE: $west,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE: $northwest,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE: $northeast
}
@onready var barred = $barred

var coords: Vector2i = Vector2i(0, 0)
var team = 0
var tile_type: int = Constants.TILE_GRASS
var init_position: Vector2 = Vector2(0, 0)
var borders = Constants.NO_BORDERS.duplicate()
var region: int = Constants.NO_REGION
var tween = null
var lighter_color
var blink_state = 0

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
	var team_color = Color(Constants.TEAM_COLORS[self.team])
	team_color.a = Constants.BLENDING_MODULATE_ALPHA
	self.lighter_color = Color.hex(0xffffffff).blend(team_color)

func _ready():
	self.position = init_position
	self.update_cell()

func update_cell():
	for b in self.borders.keys():
		self.border_objects[b].modulate = Constants.TEAM_COLORS[team] if self.borders[b] else Color.hex(0x3aa25dff)
	var team_color = Color(Constants.TEAM_COLORS[self.team])
	team_color.a = Constants.BLENDING_MODULATE_ALPHA
	self.lighter_color = Color.hex(0xffffffff).blend(team_color)
	self.modulate = self.lighter_color

func delete():
	animation_player.play("sink")

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

func set_barred(barred_val:bool):
	self.barred.visible = barred_val

func set_selected(selected: bool):
	if selected:
		self.tween = self.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_loops()
		self.tween.tween_property(self, "modulate", Color.WHITE, 0.5)
		self.tween.tween_property(self, "modulate", self.lighter_color, 0.5)
	else:
		self.modulate = self.lighter_color
		self.tween.kill()

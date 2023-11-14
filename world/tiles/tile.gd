extends Node

class_name Tile


const SINK_ANIMATION = preload("res://world/tiles/sinking_animation.tscn")

const NEUTRAL_TEXTURE = preload("res://assets/tiles/grass_neutral.png")
const TEAM_TEXTURE = preload("res://assets/tiles/grass.png")
const CRACKED_TEXTURE = preload("res://assets/tiles/grass_cracked_2.png")

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
@onready var building_sprite = $Building

class TileWorldData:
	var coords: Vector2i
	var team: int
	var region: int
	var building: int
	var marked: bool

	func _init():
		self.coords = Constants.NULL_COORDS
		self.team = Constants.NULL_TEAM
		self.region = Constants.NULL_REGION
		self.building = Constants.Building.None
		self.marked = false
	
	func save():
		return {
			"coords": self.coords,
			"team": self.team,
			"region": self.region,
			"building": self.building,
			"marked": self.marked
		}


var data = TileWorldData.new()
var init_position: Vector2 = Vector2(0, 0)
var borders = Constants.NO_BORDERS.duplicate()
var tween = null
var blink_state = 0
var delete_callable = null
var dissolving = false
var elapsed = 0.0

func init_cell(
	init_coords: Vector2,
	init_pos: Vector2,
	init_team: int,
	init_delete_callable = null
):
	self.data.coords = init_coords
	self.init_position = init_pos
	self.data.team = init_team
	self.delete_callable = init_delete_callable
	

func _ready():
	self.position = init_position
	self.update_cell()

func _process(delta):
	if dissolving:
		if elapsed > 1.0:
			self.delete_from_world()
		elapsed += delta
		self.material.set_shader_parameter("sensitivity", elapsed)

func update_cell():
	if self.data.building != Constants.Building.None:
		building_sprite.texture = Constants.BUILDINGS[self.data.building].texture
		building_sprite.visible = true
	else:
		building_sprite.visible = false
	for b in self.borders.keys():
		if self.borders[b]:
			self.border_objects[b].show()
		else:
			self.border_objects[b].hide()
	if self.data.team == 0:
		self.texture = NEUTRAL_TEXTURE
		for b in self.borders.keys():
			self.border_objects[b].self_modulate = Color.WHITE
	else:
		self.texture = TEAM_TEXTURE
		for b in self.borders.keys():
			self.border_objects[b].self_modulate = Color(Constants.TEAM_BORDER_COLORS[self.data.team])
	
	if Settings.editor_mode:
		if self.region == Constants.NULL_REGION:
			self.modulate = Color(1, 0.25, 0.25, 0.75)
		else:
			self.modulate = Color(1, 1, 1)
	else:
		self.self_modulate = Color(Constants.TEAM_COLORS[self.data.team])

func delete():
	animation_player.play("sink")
	await animation_player.animation_finished
	## dissolve
	$GPUParticles2D.emitting = true
	for b in self.borders.keys():
		self.border_objects[b].hide()
	Sfx.play(Sfx.Track.Boom)
	self.add_child(SINK_ANIMATION.instantiate())
	self.dissolving = true
	self.material.set_shader_parameter("active", true)

func delete_from_world():
	self.delete_callable.call(self.data.coords)
	self.queue_free()

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
	self.data.region = new_region
	self.update_cell()

func set_barred(barred_val:bool):
	self.barred.visible = barred_val

func set_selected(selected: bool):
	if selected:
		self.tween = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_loops()
		self.tween.tween_property(self, "self_modulate", Color(2, 2, 2), 0.5)
		self.tween.tween_property(self, "self_modulate", Color(Constants.TEAM_COLORS[self.team]), 0.5)
	else:
		self.self_modulate = Color(Constants.TEAM_COLORS[self.team])
		self.tween.kill()

func mark():
	self.data.marked = true
	#self.texture = CRACKED_TEXTURE
	self.modulate = Color.hex(0xacacacac)
	
func set_building(new_building):
	self.data.building = new_building
	self.update_cell()

func remove_building():
	self.data.building = Constants.Building.None
	self.update_cell()

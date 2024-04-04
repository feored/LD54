extends Node

class_name Tile

signal deleted

var NEUTRAL_COLOR = Color.hex(0x55d981ff)

const SINK_ANIMATION = preload("res://world/tiles/sinking_animation.tscn")
const NEUTRAL_TEXTURE = preload("res://world/tiles/images/grass_neutral.png")
const TEAM_TEXTURE = preload("res://world/tiles/images/grass.png")
const CRACKED_TEXTURE = preload("res://world/tiles/images/grass_cracked_2.png")

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
			"x": self.coords.x,
			"y": self.coords.y,
			"team": self.team,
			"region": self.region,
			"building": self.building,
			"marked": self.marked
		}

	func from_save(data):
		self.coords = Vector2i(data["x"], data["y"])
		self.team = int(data["team"])
		self.region = int(data["region"])
		self.building = int(data["building"]) if "building" in data else Constants.Building.None
		self.marked = bool(data["marked"]) if "marked" in data else false
	
	func clone():
		var new_data = TileWorldData.new()
		new_data.coords = self.coords
		new_data.team = self.team
		new_data.region = self.region
		new_data.building = self.building
		new_data.marked = self.marked
		return new_data


var data = TileWorldData.new()
var init_position: Vector2 = Vector2(0, 0)
var borders = Constants.NO_BORDERS.duplicate()
var tween = null
var blink_state = 0
var dissolving = false
var elapsed = 0.0

func init_cell(
	init_coords: Vector2,
	init_pos: Vector2,
	init_team: int,
	init_region : int,
):
	self.data.coords = init_coords
	self.init_position = init_pos
	self.data.team = init_team
	self.data.region = init_region
	self.set_name.call_deferred(StringName("Tile " + str(self.data.coords)))

func init_from_save(init_data):
	self.data.from_save(init_data)
	

func _ready():
	self.position = init_position
	self.update()

func delete():
	deleted.emit(self.data.coords)
	self.queue_free()

func _process(delta):
	if dissolving:
		if elapsed > 1.0:
			delete()
			dissolving = false
		elapsed += delta
		self.material.set_shader_parameter("sensitivity", elapsed)

func update():
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

	if self.data.marked:
		self.texture = CRACKED_TEXTURE
	else:
		self.texture = TEAM_TEXTURE
	if self.data.team == Constants.NULL_TEAM:
		for b in self.borders.keys():
			self.border_objects[b].self_modulate = Color.WHITE
	else:
		for b in self.borders.keys():
			self.border_objects[b].self_modulate = Color(Constants.TEAM_BORDER_COLORS[self.data.team])
	
	# if Settings.editor_tile_distinct_mode:
		# if self.data.region == Constants.NULL_REGION:
		# 	self.modulate = Color(1, 0.25, 0.25, 0.75)
		# else:
		# 	self.modulate = Color(1, 1, 1)
	# else:
	if self.data.team == Constants.NULL_TEAM:
		self.self_modulate = NEUTRAL_COLOR
	else:
		self.self_modulate = Color(Constants.TEAM_COLORS[self.data.team])
	if Settings.editor_tile_distinct_mode:
		self.self_modulate = Color.from_hsv((self.data.region) / 24.0, 1, 1)
	


func sink():
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

func set_team(new_team: int):
	self.data.team = new_team
	self.update()

func set_borders(new_borders: Dictionary):
	self.borders = new_borders.duplicate()
	self.update()

func set_single_border(border_changed: int , value: bool):
	self.borders[border_changed] = value
	self.update()

func set_region(new_region):
	self.data.region = new_region
	self.update()

func set_barred(barred_val:bool):
	self.barred.visible = barred_val

func set_selected(selected: bool):
	if selected:
		self.tween = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_loops()
		self.tween.tween_property(self, "self_modulate", Color(2, 2, 2), 0.5)
		self.tween.tween_property(self, "self_modulate", Color(Constants.TEAM_COLORS[self.data.team]), 0.5)
	else:
		self.self_modulate = Color(Constants.TEAM_COLORS[self.data.team])
		self.tween.kill()

func mark():
	self.data.marked = true
	#self.texture = CRACKED_TEXTURE
	#self.modulate = Color.hex(0xacacacac)
	self.animation_player.play("quake")
	self.update()

func unmark():
	self.data.marked = false
	self.animation_player.stop()
	self.update()
	
func set_building(new_building):
	self.data.building = new_building
	self.update()

func remove_building():
	self.data.building = Constants.Building.None
	self.update()

extends Control
class_name PowerCard

signal picked()

enum State {Base, Hovering}

const COLOR_INVALID = Color(1, 0.5, 0.5)
const COLOR_VALID = Color(1, 1, 1)
const ANIMATION_TIMER = 0.15

@onready var power_icon : TextureRect = %PowerIcon
@onready var power_name : Label = %PowerName
@onready var power_description : RichTextLabel = %PowerDescription
@onready var power_cost : Label = %PowerCost
@onready var shape_gui = %ShapeGUI

var shape_prefab = preload("res://ui/shapes/shape_gui.tscn")

var buyable: bool = true
var tweens = []
var power : Power
var state : State = State.Base

func set_buyable(b : bool):
	self.buyable = b
	self.power_cost.modulate = COLOR_VALID if b else COLOR_INVALID

const ICONS = {
	Power.Type.Faith: preload("res://assets/icons/trident.png"),
	Power.Type.Sacrifice: preload("res://assets/icons/skull.png"),
	Power.Type.Sink : preload("res://assets/tiles/hex_shape.png"),
	Power.Type.Emerge : preload("res://assets/tiles/hex_shape.png"),
	Power.Type.Barracks: preload("res://assets/icons/person.png"),
	Power.Type.Temple: preload("res://assets/icons/temple.png"),
	Power.Type.Fort: preload("res://assets/icons/castle.png"),
}

func clear_tweens():
	for tween in self.tweens:
		tween.kill()
	tweens.clear()

func animate(new_pos, new_rotation, new_z_index):
	if self.tweens.size() > 0:
		clear_tweens()
	var tween_pos = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween_pos.tween_property(self, "position", new_pos, ANIMATION_TIMER)
	
	var tween_rotation = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween_rotation.tween_property(self, "rotation_degrees", new_rotation, ANIMATION_TIMER)

	var tween_z_index = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween_z_index.tween_property(self, "z_index", new_z_index, ANIMATION_TIMER)

	tweens = [tween_pos, tween_rotation, tween_z_index]
	# Utils.log("Animating card to " + str(new_pos) + " " + str(new_rotation) + " " + str(new_z_index))


func mouse_inside():
	return Rect2(Vector2(), self.size).has_point(get_local_mouse_position())


# Called when the node enters the scene tree for the first time.
func _ready():
	if self.power == null:
		return
	self.power_name.text = self.power.name
	self.power_icon.texture = ICONS[self.power.id]
	if self.power.id in [Power.Type.Sink, Power.Type.Emerge]:
		self.shape_gui.roll_num(self.power.strength, self.power.id)
		self.power.shape = self.shape_gui.shape
		self.shape_gui.show()
		self.power_icon.hide()
	else:
		self.shape_gui.hide()
		self.power_icon.show()
	# self.btn.tooltip_text = self.power.description
	self.power_description.text = self.power.description
	self.power_cost.text = str(self.power.cost)

func init(p : Power):
	self.power = p
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and self.buyable:
			picked.emit()


func disconnect_picked():
	for c in self.picked.get_connections():
		self.picked.disconnect(c.callable)

func highlight(to_highlight):
	self.self_modulate = Color(0.5, 1, 0.5) if to_highlight else Color(1, 1, 1)

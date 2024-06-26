extends Control
class_name CardView

signal picked(card : CardView)

enum State { Idle, Hovered, Selected, DrawnOrDiscarded}

const COLOR_INVALID = Color(1, 0.5, 0.5)
const COLOR_VALID = Color(1, 1, 1)
const BASE_Z_INDEX = 0
const HOVER_Z_INDEX = 1

@onready var card_icon : TextureRect = %PowerIcon
@onready var card_name : Label = %PowerName
@onready var card_description : RichTextLabel = %PowerDescription
@onready var card_cost : Label = %PowerCost
@onready var shape_gui = %ShapeGUI
@onready var front : Control = %Front
@onready var back : Control = %Back
@onready var exhaust_label : Label = %ExhaustLabel

var shape_prefab = preload("res://scenes/shapes/shape_gui.tscn")

var buyable: bool = true
var tweens = []
var card : Card
var state : State = State.Idle
var card_ready : bool = false
var base_position : Vector2
var is_static : bool = false

func check_finished():
	for t in self.tweens:
		if t.is_valid() and t.is_running():
			return
	self.clear_tweens()
	

func set_buyable(b : bool):
	self.buyable = b
	self.card_cost.modulate = COLOR_VALID if b else COLOR_INVALID

func clear_tweens():
	for tween in self.tweens:
		tween.kill()
	self.tweens.clear()
	self.card_ready = true

func animate(new_pos, new_rotation, new_z_index):
	self.card_ready = false
	if self.tweens.size() > 0:
		clear_tweens()

	var tween = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_parallel()
	tween.tween_property(self, "position", new_pos, Constants.DECK_SHORT_TIMER)
	tween.tween_property(self, "rotation_degrees", new_rotation, Constants.DECK_SHORT_TIMER)
	tween.tween_property(self, "scale", Vector2(1,1), Constants.DECK_SHORT_TIMER)
	tween.tween_property(self, "z_index", new_z_index, Constants.DECK_SHORT_TIMER)

	self.tweens = [tween]

	for t in self.tweens:
		t.connect("finished", Callable(self, "check_finished"))
	# Utils.log("Animating card to " + str(new_pos) + " " + str(new_rotation) + " " + str(new_z_index))

func move(new_pos, call_when_finished = null):

	## used for draw/discard

	if self.tweens.size() > 0:
		clear_tweens()
	var tween_pos = self.create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).set_parallel()
	tween_pos.tween_property(self, "position", new_pos, Constants.DECK_LONG_TIMER)
	if call_when_finished != null:
		tween_pos.chain().tween_callback(call_when_finished)
	tween_pos.chain().tween_callback(func(): self.state = State.Idle; card_ready = true)
	tweens = [tween_pos]

	# if to_flip:
	# 	var tween_flip = self.create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	# 	tween_flip.tween_property(self, "scale", Vector2(0, 1), Constants.DECK_LONG_TIMER/2.0)
	# 	tween_flip.tween_callback(flip)
	# 	tween_flip.tween_property(self, "scale", Vector2(1, 1), Constants.DECK_LONG_TIMER/2.0)
	# 	tweens.push_back(tween_flip)

	for t in self.tweens:
		t.connect("finished", Callable(self, "check_finished"))

func flip_in_place():
	var tween_flip = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).chain()
	tween_flip.tween_property(self, "scale:x", 0.0, Constants.DECK_LONG_TIMER/2.0)
	tween_flip.tween_callback(flip)
	tween_flip.tween_property(self, "scale:x", 1.0, Constants.DECK_LONG_TIMER/2.0)
	tweens.push_back(tween_flip)
	for t in self.tweens:
		t.connect("finished", Callable(self, "check_finished"))

func discard(pos):
	self.state = State.DrawnOrDiscarded
	self.move(pos, Callable(self, "queue_free"))

func flip():
	if self.front.visible:
		self.front.hide()
		self.back.show()
	else:
		self.front.show()
		self.back.hide()

func mouse_inside():
	return Rect2(Vector2(), self.size).has_point(get_local_mouse_position())

# Called when the node enters the scene tree for the first time.
func _ready():
	self.config()

func config():
	if self.card == null:
		return
	self.card_name.text = self.card.name
	if self.card.icon != null:
		self.card_icon.texture = self.card.icon
	
	# if self.card.power in ["emerge", "sink"]:
	# 	var action_type : Action.Type = Action.Type.Emerge if self.card.power == "emerge" else Action.Type.Sink
	# 	self.shape_gui.init_with_coords(self.card., action_type)
	# 	self.shape_gui.show()
	# 	self.card_icon.hide()
	# else:
	# 	self.shape_gui.hide()
	# 	self.card_icon.show()
	# self.btn.tooltip_text = self.power.description
	self.card_description.text = "[center]" + self.card.description + "[/center]"
	self.card_cost.text = str(self.card.cost)
	self.exhaust_label.visible = self.card.exhaust
	if not self.is_static:
		self.mouse_entered.connect(Callable(self, "_on_mouse_entered"))
		self.mouse_exited.connect(Callable(self, "_on_mouse_exited"))

func init(c : Card):
	self.card = c
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and self.buyable:
			self.picked.emit(self)


func disconnect_picked():
	for c in self.picked.get_connections():
		self.picked.disconnect(c.callable)

func highlight(to_highlight):
	self.self_modulate = Color(0.5, 1, 0.5) if to_highlight else Color(1, 1, 1)

func _on_mouse_entered():
	if self.state == State.Idle and self.card_ready:
		self.animate(Vector2(self.position.x, self.position.y - 100), 0, HOVER_Z_INDEX)
		self.state = CardView.State.Hovered

func _on_mouse_exited():
	## Mouse actually exited
	if self.state == State.Hovered:
		if not self.card_ready:
			self.clear_tweens()
		self.animate(base_position, 0, BASE_Z_INDEX)
		self.state = CardView.State.Idle

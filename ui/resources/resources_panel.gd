extends PanelContainer

const shapeBoxPrefab = preload("res://ui/shapes/shape_gui_box.tscn")

@export var busy = false
@onready var goldLabel = %GoldLabel
@onready var faithLabel = %FaithLabel
@onready var shapeVBox = %ShapeVBox
@onready var shapeContainer = %ShapeContainer
@onready var animationPlayer = $AnimationPlayer

var shown = false
var pick_shape_func : Callable

var shape_boxes : Array = []
var resources : Dictionary = {}

var shape_cost_reduction = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func buy_shape_reroll():
	self.player().add_faith(-Constants.SHAPE_REROLL_COST)

func buy_shape(shape):
	self.player().add_faith(-shape_cost(shape))
	for shape_box in self.shape_boxes:
		if shape_box.picked:
			shape_box.reroll()

func shape_cost(shape):
	return max(1, shape.size() - self.shape_cost_reduction) * 10

func add_teams(teams):
	for team_id in teams:
		self.resources[team_id] = Resources.new(4, 0)
	self.resources[Constants.PLAYER_ID].init_callback(Callable(self, "update"))

func player():
	return self.resources[Constants.PLAYER_ID]
	
func add_shape():
	var shape_box = shapeBoxPrefab.instantiate()
	shape_box.init(pick_shape_func, Callable(self, "buy_shape_reroll"), Callable(self, "shape_cost"))
	self.shape_boxes.append(shape_box)
	self.shapeVBox.add_child(shape_box)

func init_shapes(init_pick_shape_func):
	self.pick_shape_func = init_pick_shape_func
	for i in Constants.SACRIFICE_SHAPES:
		add_shape()

func update():
	self.faithLabel.set_text(str(self.player().faith))
	self.goldLabel.set_text(str(self.player().gold))
	for shape_box in self.shape_boxes:
		shape_box.update(self.player().faith)
	

func reroll_all_shapes():
	for shape_box in self.shape_boxes:
		shape_box.reroll()

func lock_controls(val : bool):
	# self.faithButton.button_pressed = false
	# self.faithButton.disabled = val
	if val:
		self.hide()

func _on_shape_button_pressed():
	if not busy:
		busy = true
		if self.visible:
			animationPlayer.play("disappear")
		else:
			animationPlayer.play("appear")
func _on_mouse_exited():
	if shown and not busy:
		if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
			busy = true
			shown = false
			animationPlayer.play("disappear")

func _on_mouse_entered():
	self.shown = true

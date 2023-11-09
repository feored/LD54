extends PanelContainer

@onready var sacrificeButton = %SacrificeButton
@onready var rerollButton = %RerollButton
@onready var shape = %ShapeGUI

var picked: int = false

var sacrifice_func : Callable
var reroll_cost : Callable
var shape_cost : Callable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(init_sacrifice_func, init_reroll_cost, init_shape_cost):
	self.sacrifice_func = init_sacrifice_func
	self.reroll_cost = init_reroll_cost
	self.shape_cost = init_shape_cost

func pick():
	self.picked = true
	sacrifice_func.call(shape.shape.shape.keys())

func reroll():
	self.shape.reroll()
	self.sacrificeButton.set_text(str(shape_cost.call(shape.shape.shape.keys())))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_reroll_button_pressed():
	self.reroll()
	self.reroll_cost.call()

func _on_sacrifice_button_pressed():
	self.pick()

func update(faith):
	sacrificeButton.set_text(str(shape_cost.call(shape.shape.shape.keys())))
	if faith < Constants.SHAPE_REROLL_COST:
		rerollButton.set_disabled(true)
	else:
		rerollButton.set_disabled(false)

	if faith < shape_cost.call(shape.shape.shape):
		sacrificeButton.set_disabled(true)
	else:
		sacrificeButton.set_disabled(false)

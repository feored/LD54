extends PanelContainer

@onready var sacrificeButton = %SacrificeButton
@onready var rerollButton = %RerollButton
@onready var shape = %ShapeGUI

@export var id : int = 0
var sacrifice_func = null
var reroll_cost = null
var picked: int = false

# Called when the node enters the scene tree for the first time.
func _ready():
	sacrificeButton.set_text(str( shape.shape.shape.keys().size()))

func init(init_id, init_sacrifice_func, init_reroll_cost):
	self.id = init_id
	self.sacrifice_func = init_sacrifice_func
	self.reroll_cost = init_reroll_cost

func pick():
	self.picked = true
	sacrifice_func.call(shape.shape.shape.keys())

func reroll(free = false):
	self.shape.reroll()
	self.sacrificeButton.set_text(str( shape.shape.shape.keys().size()))
	if not free:
		self.reroll_cost.call()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_reroll_button_pressed():
	self.reroll()

func _on_sacrifice_button_pressed():
	self.pick()

func update_buttons_state(favor):
	if favor < Constants.SHAPE_REROLL_COST:
		rerollButton.set_disabled(true)
	else:
		rerollButton.set_disabled(false)

	if favor < self.shape.shape.shape.keys().size():
		sacrificeButton.set_disabled(true)
	else:
		sacrificeButton.set_disabled(false)

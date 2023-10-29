extends PanelContainer

@onready var sacrificeButton = %SacrificeButton
@onready var shape = %ShapeGUI

@export var id : int = 0
var sacrifice_func = null
var reroll_func = null

# Called when the node enters the scene tree for the first time.
func _ready():
	sacrificeButton.set_text(str( shape.shape.shape.keys().size()))

func init(init_id, init_sacrifice_func, init_reroll_func):
	self.id = init_id
	self.sacrifice_func = init_sacrifice_func
	self.reroll_func = init_reroll_func

func pick():
	sacrifice_func.call(id, shape.shape.shape.keys())

func reroll():
	self.shape.reroll()
	self.reroll_func.call()
	self.sacrificeButton.set_text(str( shape.shape.shape.keys().size()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_reroll_button_pressed():
	self.reroll()

func _on_sacrifice_button_pressed():
	self.pick()

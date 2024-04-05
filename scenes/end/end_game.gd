extends Node

@onready var world = $World


# Called when the node enters the scene tree for the first time.
func _ready():
	world.init(func (x): print(x))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

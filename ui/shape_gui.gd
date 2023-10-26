extends Control
@onready var shape = $Shape


# Called when the node enters the scene tree for the first time.
func _ready():
	self.shape.init()


func _process(delta):
	pass

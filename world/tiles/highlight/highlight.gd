extends Sprite2D

const COLOR_IMPOSSIBLE = Color.RED
const COLOR_POSSIBLE = Color.GREEN


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func highlight(val: bool):
	self.modulate = COLOR_POSSIBLE if val else COLOR_IMPOSSIBLE

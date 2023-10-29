extends Control

### $Shape does not work?
@onready var shape = $"Shape"

# Called when the node enters the scene tree for the first time.
func _ready():
	shape.init()
	print(shape.shape)
	self.custom_control()


func reroll():
	self.shape.reroll()
	self.custom_control()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func custom_control():
	if not self.shape:
		set_custom_minimum_size(Vector2.ZERO)
		return 
	var sorted_keys = self.shape.shape.values().duplicate()
	sorted_keys.sort_custom(func(a,b): return a.position.x < b.position.x)
	var offset_x = -sorted_keys[0].position.x + Constants.TILE_SIZE/2
	var width = Constants.TILE_SIZE + sorted_keys[sorted_keys.size()-1].position.x - sorted_keys[0].position.x
	sorted_keys.sort_custom(func(a,b): return a.position.y < b.position.y)
	var height = Constants.TILE_SIZE + sorted_keys[sorted_keys.size()-1].position.y - sorted_keys[0].position.y
	var offset_y = -sorted_keys[0].position.y + Constants.TILE_SIZE/2
	set_custom_minimum_size(Vector2(width, height))
	self.shape.position = Vector2(offset_x, offset_y)

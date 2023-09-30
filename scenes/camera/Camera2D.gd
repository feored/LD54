extends Camera2D

const edge = 24
const step = 2

const limit = 72

@onready var viewport_size = get_viewport().content_scale_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var local_mouse_pos = get_local_mouse_position()
	if local_mouse_pos.x < edge and position.x > -limit:
		position.x -= step
	elif local_mouse_pos.x > viewport_size.x - edge	and position.x < limit:
		position.x += step
	elif local_mouse_pos.y < edge  and position.y > -limit:
		position.y -= step
	elif local_mouse_pos.y > viewport_size.y - edge	and position.y < limit:
		position.y += step
	

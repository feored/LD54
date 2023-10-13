extends Camera2D


var active = true

const edge = 24
const step = 5
const limit = 24*8


@onready var viewport_size = get_viewport().content_scale_size
var start_position = Constants.NULL_POS
var is_dragging = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	

func move():
	if not active:
		return
	var local_mouse_pos = get_local_mouse_position()
	if local_mouse_pos.x < start_position.x and position.x < limit:
		position.x += step
	if local_mouse_pos.x > start_position.x and position.x > -limit:
		position.x -= step
	if local_mouse_pos.y < start_position.y and position.y < limit:
		position.y += step
	if local_mouse_pos.y > start_position.y and position.y > -limit:
		position.y -= step

func _unhandled_input(event):
	if Settings.input_locked:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_position = get_local_mouse_position()
			else:
				start_position = Constants.NULL_POS
				is_dragging = false
	elif event is InputEventMouseMotion:
		if start_position != Constants.NULL_POS:
			move()
			start_position = get_local_mouse_position()
			is_dragging = true

func move_bounded(target, precision = 1):
	if not active:
		return
	self.position = target - Vector2(self.viewport_size/2)
	var arrived_center = target
	while abs((arrived_center - get_screen_center_position()).length_squared()) > precision:
		await Utils.wait(0.1)

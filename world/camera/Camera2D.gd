extends Camera2D


var active = true

const LIMIT_X = 24*(Constants.WORLD_CAMERA_BOUNDS.x)-640
const LIMIT_Y = 24*(Constants.WORLD_CAMERA_BOUNDS.y)-360


@onready var viewport_size = get_viewport().content_scale_size
var start_position = Constants.NULL_POS
var is_dragging = false



func _ready():
	self.position_smoothing_enabled = false
	self.position_smoothing_speed = Constants.CAMERA_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if not active or Settings.input_locked:
		return
	if Input.is_action_pressed("map_left"):
		position = Vector2(position.x - Constants.CAMERA_SPEED/2, position.y)
	elif Input.is_action_pressed("map_right"):
		position = Vector2(position.x + Constants.CAMERA_SPEED/2, position.y)
	if Input.is_action_pressed("map_up"):
		position = Vector2(position.x, position.y  - Constants.CAMERA_SPEED/2)
	elif Input.is_action_pressed("map_down"):
		position = Vector2(position.x,  position.y + Constants.CAMERA_SPEED/2)
	


func move():
	if not active:
		return
	var local_mouse_pos = get_local_mouse_position()
	var new_position = position + (start_position - local_mouse_pos)
	if new_position.x < -LIMIT_X:
		new_position.x = -LIMIT_X
	elif new_position.x > LIMIT_X:
		new_position.x = LIMIT_X
	if new_position.y < -LIMIT_Y:
		new_position.y = -LIMIT_Y
	elif new_position.y > LIMIT_Y:
		new_position.y = LIMIT_Y
	self.position = new_position
	return local_mouse_pos

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
			start_position = move()
			is_dragging = true

func move_instant(target):
	if not active:
		return
	self.position = target - Vector2(self.viewport_size/2)


func move_smoothed(target, precision = 1):
	if not active:
		return
	Settings.input_locked = true
	self.position_smoothing_enabled = true
	self.position = target - Vector2(self.viewport_size/2)
	var arrived_center = target
	while abs((arrived_center - get_screen_center_position()).length_squared()) > precision:
		await Utils.wait(0.1)
	self.position_smoothing_enabled = false
	Settings.input_locked = false

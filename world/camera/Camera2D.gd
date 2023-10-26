extends Camera2D


var active = true

const LIMIT_X = 24*(Constants.WORLD_CAMERA_BOUNDS.x)-640
const LIMIT_Y = 24*(Constants.WORLD_CAMERA_BOUNDS.y)-360

const POSITION_SMOOTHED_SPEED = 5.0
const POSITION_SMOOTHED_SPEED_SKIP = 10.0
const ZOOM_STEP = Vector2(0.05, 0.05)

@onready var viewport_size = get_viewport().content_scale_size
var start_position = Constants.NULL_POS
var is_dragging = false
var zoom_speed = 0.05




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
	

func zoom_camera(zoom_factor, mouse_position):
	print(mouse_position)
	self.viewport_size = get_viewport().size
	print(self.viewport_size, "viewport_size")
	var previous_zoom = self.zoom
	self.zoom += self.zoom * zoom_factor
	self.position += ((self.viewport_size * 0.5) - mouse_position) * (self.zoom-previous_zoom)

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
	if Settings.input_locked or not active:
		return
	if event.is_action_pressed("zoom_in"):
		zoom_camera(zoom_speed, event.position)
	elif event.is_action_pressed("zoom_out"):
		zoom_camera(-zoom_speed, event.position)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_position = get_local_mouse_position()
				is_dragging = true
			else:
				start_position = Constants.NULL_POS
				is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		if start_position != Constants.NULL_POS:
			start_position = move()

func move_instant(target):
	if not active:
		return
	is_dragging = false
	self.position = target - Vector2(self.viewport_size/2)

func skip(val: bool):
	if self.position_smoothing_enabled:
		self.position_smoothing_speed = POSITION_SMOOTHED_SPEED_SKIP if val else POSITION_SMOOTHED_SPEED


func move_smoothed(target, precision = 1):
	if not active:
		return
	is_dragging = false
	Settings.input_locked = true
	self.position_smoothing_enabled = true
	self.position = target - Vector2(self.viewport_size/2)
	self.position_smoothing_speed = POSITION_SMOOTHED_SPEED_SKIP if Settings.skipping else POSITION_SMOOTHED_SPEED
	var arrived_center = target
	while abs((arrived_center - get_screen_center_position()).length_squared()) > precision:
		await Utils.wait(0.1)
	self.position_smoothing_enabled = false
	Settings.input_locked = false

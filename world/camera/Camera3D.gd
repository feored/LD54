extends Camera3D

var active = true

var LIMIT_X_NEGATIVE = Constants.CAMERA_CENTER.x - Constants.VIEWPORT_SIZE.x * 0.5
var LIMIT_X_POSITIVE = Constants.CAMERA_CENTER.x + Constants.VIEWPORT_SIZE.x * 0.5
var LIMIT_Z_NEGATIVE = Constants.CAMERA_CENTER.y - Constants.VIEWPORT_SIZE.y * 0.5 * 16 / 9
var LIMIT_Z_POSITIVE = Constants.CAMERA_CENTER.y + Constants.VIEWPORT_SIZE.y * 0.5 * 16 / 9


func _ready():
	if self.position == Vector3.ZERO:
		self.position = Constants.CAMERA_CENTER


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if not active or Settings.input_locked:
		pass  #return
	var new_position = self.position
	if Input.is_action_pressed("map_left"):
		new_position = Vector3(
			self.position.x - Constants.CAMERA_SPEED / 2, self.position.y, self.position.z
		)
	elif Input.is_action_pressed("map_right"):
		new_position = Vector3(
			self.position.x + Constants.CAMERA_SPEED / 2, self.position.y, self.position.z
		)
	if Input.is_action_pressed("map_up"):
		new_position = Vector3(
			self.position.x, self.position.y, self.position.z - Constants.CAMERA_SPEED / 2
		)
	elif Input.is_action_pressed("map_down"):
		new_position = Vector3(
			self.position.x, self.position.y, self.position.z + Constants.CAMERA_SPEED / 2
		)
	if new_position.x < LIMIT_X_NEGATIVE:
		new_position.x = LIMIT_X_NEGATIVE
	elif new_position.x > LIMIT_X_POSITIVE:
		new_position.x = LIMIT_X_POSITIVE
	if new_position.z < LIMIT_Z_NEGATIVE:
		new_position.z = LIMIT_Z_NEGATIVE
	elif new_position.z > LIMIT_Z_POSITIVE:
		new_position.z = LIMIT_Z_POSITIVE
	self.position = new_position


func move():
	if not active:
		return
	pass


func _unhandled_input(event):
	if Settings.input_locked:
		return
	# if event is InputEventMouseButton:
	# 	if event.button_index == MOUSE_BUTTON_LEFT:
	# 		if event.pressed:
	# 			start_position = get_viewport().get_mouse_position()

	# 			is_dragging = true
	# 		else:
	# 			start_position = NULL_POS
	# 			is_dragging = false
	# elif event is InputEventMouseMotion and is_dragging:
	# 	if start_position != NULL_POS:
	# 		start_position = move()


func move_instant(target):
	if not active:
		return
	pass
	# is_dragging = false
	# self.position = Utils.vec2to3(target - Vector2(self.viewport_size/2))


func skip(val: bool):
	pass
	# if self.position_smoothing_enabled:
	# 	self.position_smoothing_speed = POSITION_SMOOTHED_SPEED_SKIP if val else POSITION_SMOOTHED_SPEED


func move_smoothed(target, precision = 1):
	if not active:
		return
	if !Settings.get_setting(Settings.Setting.AutoCameraFocus):
		return
	pass
	# is_dragging = false
	# self.position_smoothing_enabled = true
	# self.position = target - Vector2(self.viewport_size/2)
	# self.position_smoothing_speed = POSITION_SMOOTHED_SPEED_SKIP if Settings.skipping else POSITION_SMOOTHED_SPEED
	# var arrived_center = target
	# while abs((arrived_center - self.viewport.get_screen_center_position()).length_squared()) > precision:
	# 	await Utils.wait(0.1)
	# self.position_smoothing_enabled = false

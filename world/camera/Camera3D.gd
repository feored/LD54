extends Camera3D

signal target_reached

@onready var pivot = get_parent()
@onready var socket = pivot.get_parent()

const EPSILON = 0.05
const NULL_POSITION = Vector3(-9999, -9999, -9999)
const FOV_MIN = 15
const FOV_MAX = 100
const HEIGHT_MIN = 50
const HEIGHT_MAX = 750
const Z_FACTOR = 10.0/200

const CAMERA_ZOOM_STEP = 10
const CAMERA_MOVE_SPEED = 200
const CAMERA_ROTATION_SPEED = 10

enum State { IDLE, AUTOMOVE, DRAGGING, ROTATING }
var state = State.IDLE

var target = NULL_POSITION
var active = true

func _process(delta):
	if state == State.AUTOMOVE && target != NULL_POSITION:
		var new_pos = pivot.position.lerp(target, delta * 10)
		if new_pos.distance_to(target) < EPSILON:
			self.pivot.position = target
			self.state = State.IDLE
			self.target_reached.emit()
		else:
			self.pivot.position = new_pos

func _unhandled_input(event):
	if !active:
		return
	var delta = get_process_delta_time()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				self.state = State.ROTATING
			else:
				self.state = State.IDLE
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				self.state = State.DRAGGING
			else:
				self.state = State.IDLE
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			self.position.y = max(self.position.y - CAMERA_ZOOM_STEP, HEIGHT_MIN)
			self.position.z = self.position.y * Z_FACTOR
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			self.position.y = min(self.position.y + CAMERA_ZOOM_STEP, HEIGHT_MAX)
			self.position.z = self.position.y * Z_FACTOR
	elif event is InputEventMouseMotion and self.state != State.IDLE:
		if self.state == State.ROTATING:
			self.pivot.rotation_degrees.y -= event.relative.x * delta * CAMERA_ROTATION_SPEED
			# self.rotation_degrees.x -= event.relative.y * delta * CAMERA_ROTATION_SPEED
		elif self.state == State.DRAGGING:
			var dx = (event.relative.x * delta * CAMERA_MOVE_SPEED * self.position.y / HEIGHT_MAX)
			var dy = (event.relative.y * delta * CAMERA_MOVE_SPEED * self.position.y / HEIGHT_MAX)
			var translated_x = dx * cos(self.pivot.rotation.y) +  dy * sin(self.pivot.rotation.y)
			var translated_y = -dx * sin(self.pivot.rotation.y) + dy * cos(self.pivot.rotation.y)
			self.pivot.position.x -= translated_x
			self.pivot.position.z -= translated_y

func move(new_pos, smoothed = false):
	if !smoothed:
		self.pivot.position = new_pos
		return
	self.target = Vector3(new_pos.x, self.pivot.position.y, new_pos.y)
	self.state = State.AUTOMOVE

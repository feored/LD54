extends PanelContainer

@onready var building_name = %Name
@onready var tooltip = %Tooltip
@onready var build_container = %BuildContainer
@onready var animation_player = $AnimationPlayer

@export var busy = false
var building = Constants.NULL_BUILDING
var built = false

var disappeared : Callable

const MARGIN = 5

func appear():
	self.busy = true
	animation_player.play("appear")
		
func disappear_instant():
	self.hide()
	self.scale = Vector2.ZERO
	
func disappear():
	#self.busy = true
	#animation_player.play("disappear")
	on_disappear()

func on_disappear():
	if self.disappeared != null:
		self.disappeared.call()
	self.queue_free()

func init(init_building, init_built, disappear_func):
	self.building = init_building
	self.built = init_built
	self.disappeared = disappear_func

func update():
	self.building_name.text = Constants.BUILDINGS[self.building].name
	self.tooltip.text = Constants.BUILDINGS[self.building].tooltip
	if not self.built:
		self.build_container.show()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.update()
	self.appear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not busy:
		var mouse_pos = get_local_mouse_position()
		if (mouse_pos.x < -MARGIN * 3) or (mouse_pos.x > self.size.x + MARGIN) or (mouse_pos.y < -MARGIN * 3) or (mouse_pos.y > self.size.y + MARGIN):
			self.disappear()

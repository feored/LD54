extends PanelContainer

@onready var building_name = %Name
@onready var tooltip = %Tooltip
@onready var cost = %Cost
@onready var animation_player = $AnimationPlayer

var building = Constants.Building.None
var built = false

var disappeared : Callable

const MARGIN = 5

func appear():
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
	self.cost.text = str(Constants.BUILDINGS[self.building].cost)


# Called when the node enters the scene tree for the first time.
func _ready():
	self.update()
	self.appear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

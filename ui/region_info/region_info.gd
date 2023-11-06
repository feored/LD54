extends PanelContainer

const ANIM_APPEAR = "appear"
const ANIM_DISAPPEAR = "disappear"

@onready var owner_label = %OwnerLabel
@onready var size_label = %SizeLabel
@onready var favor_label = %FavorLabel
@onready var gold_label = %GoldLabel
@onready var resources_container = %ResourcesContainer
@onready var animation_player = $AnimationPlayer

var region_owner : int = 0
var region_size : int = 0
var favor : int = 0
var gold : int = 0

var shown = false


# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()

func update():
	owner_label.text = Constants.TEAM_NAMES[region_owner]
	size_label.text = str(region_size)
	favor_label.text = str(favor)
	gold_label.text = str(gold)
	if region_owner == 0:
		resources_container.hide()
	else:
		resources_container.show()
	self.reset_size()

func init(init_region_owner, init_region_size, init_favor, init_gold):
	region_owner = init_region_owner
	region_size = init_region_size
	favor = init_favor
	gold = init_gold
	self.update()
	self.appear()

func appear():
	animation_player.play(ANIM_APPEAR)

func disappear():
	animation_player.play(ANIM_DISAPPEAR)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

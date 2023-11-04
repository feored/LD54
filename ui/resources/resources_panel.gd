extends PanelContainer

enum ResourcesContainerState { None, Favor, Gold }

const shapeBoxPrefab = preload("res://ui/shapes/shape_gui_box.tscn")
const itemBoxPrefab = preload("res://ui/items/item_gui.tscn")

@onready var favorButton = %FavorButton
@onready var goldButton = %GoldButton
@onready var shapeVBox = %ShapeVBox
@onready var shapeContainer = %ShapeContainer
@onready var shopContainer = %ShopContainer
@onready var shopVBox = %ShopVBox

var shape_boxes : Array = []
var resources : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func reroll_shape():
	self.player().add_favor(-Constants.SHAPE_REROLL_COST)

func buy_item(item_info):
	self.player().add_gold(-item_info.cost)

func add_teams(teams):
	for team_id in teams:
		self.resources[team_id] = Resources.new(0, 0)
	self.resources[Constants.PLAYER_ID].init_callback(Callable(self, "update"))

func player():
	return self.resources[Constants.PLAYER_ID]

func init_shop():
	for item in Constants.DEFAULT_ITEMS:
		var item_box = itemBoxPrefab.instantiate()
		item_box.init(item, Callable(self, "buy_item"))
		self.shopVBox.add_child(item_box)
	
func init_shapes(pick_shape_func):
	for i in Constants.SACRIFICE_SHAPES:
		var shape_box = shapeBoxPrefab.instantiate()
		shape_box.init(i, pick_shape_func, Callable(self, "reroll_shape"))
		self.shape_boxes.append(shape_box)
		self.shapeVBox.add_child(shape_box)

func update():
	self.favorButton.set_text(str(self.player().favor))
	self.goldButton.set_text(str(self.player().gold))
	for shape_box in self.shape_boxes:
		shape_box.update_buttons_state(self.player().favor)
	for item_box in self.shopVBox.get_children():
		item_box.update_button_state(self.player().gold)

func update_display(clicked: ResourcesContainerState, active: bool):
	if active:
		self.show()
		if clicked == ResourcesContainerState.Favor:
			self.shapeContainer.show()
			self.shopContainer.hide()
		elif clicked == ResourcesContainerState.Gold:
			self.shapeContainer.hide()
			self.shopContainer.show()
	else:
		self.hide()

func lock_controls(val : bool):
	self.favorButton.disabled = val
	self.goldButton.disabled = val
	if val:
		self.hide()


func _on_favor_button_toggled(button_pressed: bool):
	update_display(ResourcesContainerState.Favor, button_pressed)


func _on_gold_button_toggled(button_pressed: bool):
	update_display(ResourcesContainerState.Gold, button_pressed)

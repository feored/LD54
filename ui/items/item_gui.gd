extends PanelContainer

@onready var item_texture = %ItemTexture
@onready var button = %Button
@onready var button_container = %ButtonContainer

var item_info = null
var buy_func = null


# Called when the node enters the scene tree for the first time.
func _ready():
	self.item_texture.texture = self.item_info.texture
	self.button.text = str(self.item_info.cost)
	self.tooltip_text = self.item_info.tooltip
	self.item_texture.tooltip_text = self.item_info.tooltip
	self.button_container.tooltip_text = self.item_info.tooltip
	%Label.text = self.item_info.tooltip

func init(item_id: int, init_buy_func):
	self.item_info = Constants.ITEMS[item_id]
	self.buy_func = init_buy_func

func update(gold):
	self.button.disabled = gold < self.item_info.cost

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	self.buy_func.call(self.item_info)

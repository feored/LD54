extends PanelContainer

@onready var rect = $MarginContainer/TeamTurn
var color = Color.WHITE
var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_color(self.color)
	self.set_active(self.active)

func init(new_color, is_active):
	self.color = new_color
	self.active = is_active

func set_color(new_color):
	self.color = new_color
	rect.color = self.color
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_active(val):
	self.active = val
	self.self_modulate = Color.WHITE if self.active else Color.TRANSPARENT

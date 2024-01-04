extends Control

signal picked()

@onready var power_icon : TextureRect = %PowerIcon
@onready var power_description : Label = %PowerDescription
@onready var power_cost : Label = %PowerCost

var power : Power

const ICONS = {
	Power.Type.Faith: preload("res://assets/icons/trident.png"),
	Power.Type.Sink : preload("res://assets/tiles/hex_shape.png"),
	Power.Type.Emerge : preload("res://assets/tiles/hex_shape.png"),
	Power.Type.Barracks: preload("res://assets/icons/person.png"),
	Power.Type.Temple: preload("res://assets/icons/temple.png"),
	Power.Type.Fort: preload("res://assets/icons/castle.png"),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	if self.power == null:
		return
	self.power_icon.texture = ICONS[self.power.id]
	self.power_description.text = self.power.description
	self.power_cost.text = str(self.power.cost)

func init(p : Power):
	self.power = p

func _on_button_pressed():
	picked.emit()

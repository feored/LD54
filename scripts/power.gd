class_name Power
extends RefCounted

enum Type { Faith, Sacrifice, Sink, Emerge, Barracks, Temple, Fort, Shrine, Seal }

var id: Type
var strength: int = 0
var cost: int = 0
var name: String = ""
var description: String = ""
var shape: Shape = null

var faith_icon_BBCode: String = "[img]res://assets/icons/trident.png[/img]"


func _init(init_id: Type, init_strength: int) -> void:
	self.id = init_id
	self.strength = init_strength
	self.cost = get_cost()
	self.name = get_name()
	self.description = "[center]" + get_description() + "[/center]"


func get_cost() -> int:
	match self.id:
		Type.Faith:
			return 0
		Type.Sacrifice:
			return 0
		Type.Sink:
			return 1
		Type.Emerge:
			return 1
		Type.Barracks:
			return 1
		Type.Temple:
			return 1
		Type.Fort:
			return 2
		Type.Shrine:
			return 2
		Type.Seal:
			return 1
		_:
			return 0


func get_description() -> String:
	match self.id:
		Type.Faith:
			return "Gain 1 " + faith_icon_BBCode
		Type.Sacrifice:
			return "Sacrifice all units in a region to draw 2 cards."
		Type.Sink:
			return "Sink " + str(self.strength) + " tiles."
		Type.Emerge:
			return "Emerge " + str(self.strength) + " tiles."
		Type.Barracks:
			return (
				"Build a barracks. The barracks generate "
				+ str(Constants.BARRACKS_UNITS_PER_TURN)
				+ " units per turn."
			)
		Type.Temple:
			return "Build a temple. The temple lets you draw 1 additional card per turn."
		Type.Fort:
			return "Build a fort. The fort defends against 20 units when attacked."
		Type.Shrine:
			return "Build a shrine. The shrine generates 1 card per turn."
		Type.Seal:
			return "The region this seal belongs to can resist one marking of Neptune."
		_:
			return "Unknown power."


func get_name() -> String:
	match self.id:
		Type.Faith:
			return "Faith"
		Type.Sacrifice:
			return "Sacrifice"
		Type.Sink:
			return "Sink"
		Type.Emerge:
			return "Emerge"
		Type.Barracks:
			return "Barracks"
		Type.Temple:
			return "Temple"
		Type.Fort:
			return "Fort"
		Type.Shrine:
			return "Shrine"
		Type.Seal:
			return "Seal"
		_:
			return "Unknown power."


func get_building():
	match self.id:
		Type.Barracks:
			return Constants.Building.Barracks
		Type.Temple:
			return Constants.Building.Temple
		Type.Fort:
			return Constants.Building.Fort
		Type.Shrine:
			return Constants.Building.Shrine
		Type.Seal:
			return Constants.Building.Seal
		_:
			return Constants.Building.None

class_name Power
extends RefCounted

enum Type { Faith, Sacrifice, Sink, Emerge, Barracks, Temple, Fort, Shrine }

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
			return self.strength
		Type.Emerge:
			return self.strength
		Type.Barracks:
			return 2
		Type.Temple:
			return 5
		Type.Fort:
			return 10
		Type.Shrine:
			return 10
		_:
			return 0


func get_description() -> String:
	match self.id:
		Type.Faith:
			return "Gain " + str(self.strength) + faith_icon_BBCode
		Type.Sacrifice:
			return "Sacrifice all units in a region to gain as much " + faith_icon_BBCode + " ."
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
			return (
				"Build a temple. The temple generates "
				+ str(Constants.TEMPLE_FAITH_PER_TURN)
				+ " faith per turn."
			)
		Type.Fort:
			return "Build a fort. The fort defends against 20 units when attacked."
		Type.Shrine:
			return "Build a shrine. The shrine generates 1 card per turn."
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
		_:
			return Constants.Building.None

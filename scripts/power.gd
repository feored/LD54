class_name Power
extends RefCounted

enum Type { Offering, Sacrifice, Sink, Emerge, Barracks, Temple, Fort, Oracle, Seal, Prayer }

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
		Type.Offering:
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
			return 2
		Type.Fort:
			return 2
		Type.Oracle:
			return 2
		Type.Seal:
			return 1
		Type.Prayer:
			return 0
		_:
			return 0


func get_description() -> String:
	match self.id:
		Type.Offering:
			return "Make an offering to Neptune and gain 1 " + faith_icon_BBCode
		Type.Sacrifice:
			return "Sacrifice all units in a region to draw 2 cards."
		Type.Sink:
			return "Sink " + str(self.strength) + " tiles."
		Type.Emerge:
			return "Emerge " + str(self.strength) + " tiles."
		Type.Barracks:
			return (
				"[Building] The barracks generate "
				+ str(Constants.BARRACKS_UNITS_PER_TURN)
				+ " units per turn."
			)
		Type.Temple:
			return "[Building] The temple generates 1 " + faith_icon_BBCode + " per turn."
		Type.Fort:
			return "[Building] The fort defends against 20 units when attacked."
		Type.Oracle:
			return "[Building] The oracle lets you draw 1 additional card per turn."
		Type.Seal:
			return "[Building] The region this seal belongs to can resist one marking of Neptune."
		Type.Prayer:
			return "Gain 1 " + faith_icon_BBCode + " but discard up to 2 other cards at random."
		_:
			return "Unknown power."


func get_name() -> String:
	match self.id:
		Type.Offering:
			return "Offering"
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
		Type.Oracle:
			return "Oracle"
		Type.Seal:
			return "Seal"
		Type.Prayer:
			return "Prayer"
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
		Type.Oracle:
			return Constants.Building.Oracle
		Type.Seal:
			return Constants.Building.Seal
		_:
			return Constants.Building.None

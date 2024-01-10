class_name Power
extends RefCounted

enum Type {
	Offering,
	Sacrifice,
	Sink,
	Emerge,
	Barracks,
	Temple,
	Fort,
	Oracle,
	Seal,
	Prayer,
	Reinforcements
}

const INFO = {
	Type.Offering:
	{
		"cost": 0,
		"name": "Offering",
	},
	Type.Sacrifice:
	{
		"cost": 0,
		"name": "Sacrifice",
	},
	Type.Sink:
	{
		"cost": 1,
		"name": "Sink",
	},
	Type.Emerge:
	{
		"cost": 1,
		"name": "Emerge",
	},
	Type.Barracks:
	{
		"cost": 1,
		"name": "Barracks",
	},
	Type.Temple:
	{
		"cost": 2,
		"name": "Temple",
	},
	Type.Fort:
	{
		"cost": 3,
		"name": "Fort",
	},
	Type.Oracle:
	{
		"cost": 2,
		"name": "Oracle",
	},
	Type.Seal:
	{
		"cost": 1,
		"name": "Seal",
	},
	Type.Prayer:
	{
		"cost": 0,
		"name": "Prayer",
	},
	Type.Reinforcements:
	{
		"cost": 1,
		"name": "Reinforcements",
	},
}

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
	self.cost = INFO[self.id].cost
	self.name = INFO[self.id].name
	self.description = "[center]" + get_description() + "[/center]"


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
		Type.Reinforcements:
			return "Reinforce a region with 10 units."
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

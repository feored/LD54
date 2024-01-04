class_name Power
extends RefCounted

enum Type {
	Faith,
	Sacrifice,
	Sink,
	Emerge,
	Barracks,
	Temple,
	Fort,
}

var id: Type
var strength: int = 0
var cost: int = 0
var name: String = ""
var description: String = ""


func _init(init_id: Type, init_strength: int) -> void:
	self.id = init_id
	self.strength = init_strength
	self.cost = get_cost()
	self.name = get_name()
	self.description = get_description()


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
		_:
			return 0


func get_description() -> String:
	match self.id:
		Type.Faith:
			return "Gain " + str(self.strength) + " faith."
		Type.Sacrifice:
			return "Sacrifice all units in a region to gain as much faith."
		Type.Sink:
			return "Sink " + str(self.strength) + " tiles."
		Type.Emerge:
			return "Emerge " + str(self.strength) + " tiles."
		Type.Barracks:
			return "Build a barracks."
		Type.Temple:
			return "Build a temple."
		Type.Fort:
			return "Build a fort."
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
		_:
			return "Unknown power."

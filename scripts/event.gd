class_name Event

enum Type { None, Move, Attack, Build, Sacrifice, EndTurn, DrawCard, PlayCard, Discard }

var duration_left : float;
var type : Type;

func _init(p_duration : float, p_type : Type) -> void:
	self.duration_left = p_duration;
	self.type = p_type;

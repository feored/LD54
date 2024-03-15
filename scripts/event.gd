class_name Event

enum Type { None, Move, Attack, Build, Sacrifice, EndTurn, DrawCard, PlayCard, Discard }

var duration_left : float;
var type : Type;
var effect : Effect;

func _init(p_duration : float, p_type : Type, p_effect : Effect) -> void:
	duration_left = p_duration;
	self.type = p_type;
	self.effect = p_effect;
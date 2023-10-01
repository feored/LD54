extends RefCounted
class_name ItemBase

var effectPhase: int = Constants.ItemEffectPhase.NONE
var modifier: float = 1
var duration = 2;

func _init(init_phase):
    self.effectPhase = init_phase

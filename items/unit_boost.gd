extends ItemBase
class_name UnitBoost

func _init():
    self.effectPhase = Constants.ItemEffectPhase.UNIT_GENERATION
    self.modifier = 2
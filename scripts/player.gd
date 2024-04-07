extends RefCounted
class_name Player

var team: int = 0
var eliminated: bool = false
var resources: Dictionary = DEFAULT_RESOURCES.duplicate()
var cards_in_use: Array = []
var is_bot: bool = false
var bot: Bot = null


func _to_string():
	return "Player " + str(team)


const DEFAULT_RESOURCES = {"faith": 0, "faith_per_turn": 2, "cards_per_turn": 5}

func compute_resource(r):
	var res = self.resources.duplicate()
	for effect in Effects.active_effects[self].filter(func(e): return e.name == r):
		var expression = Expression.new()
		expression.parse(effect.value, res.keys())
		var result = expression.execute(res.values())
		res[effect.name] = result
	return res[r]

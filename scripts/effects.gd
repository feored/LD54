extends Node

var effect_to_apply : Callable
var get_current_player : Callable

var active_effects: Dictionary = {}


func init(players, effect_apply_func, get_current_player_func):
	self.active_effects.clear()
	self.effect_to_apply = effect_apply_func
	self.get_current_player = get_current_player_func
	for p in players:
		self.active_effects[p] = []

func add(e : Effect):
	Utils.log("Adding effect: " + str(e) + " for player " + str(self.get_current_player.call()))
	var p = self.get_current_player.call()
	self.active_effects[p].push_back(e)

func trigger(t : Effect.Trigger):
	var p = self.get_current_player.call()
	var duration_affected = self.active_effects[p].filter(func (e): return e.duration_trigger == t)
	var to_trigger = self.active_effects[p].filter(func (e): return e.trigger == t)
	for e in to_trigger:
		Utils.log("Triggering effect: " + str(e) + " for player " + str(p))
		self.effect_to_apply.call(e)
	for e in duration_affected:
		e.duration -= 1
		if e.duration <= 0:
			self.active_effects.erase(e)
			Utils.log("Effect " + str(e) + " has expired for player " + str(p))

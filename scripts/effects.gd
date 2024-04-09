extends Node

var apply_active : Callable
var get_current_player : Callable

var effects: Dictionary = {}


func init(players, apply_active_func, get_current_player_func):
	self.effects.clear()
	self.apply_active = apply_active_func
	self.get_current_player = get_current_player_func
	for p in players:
		self.effects[p] = []

func add(e : Effect, p : Player = null):
	if p == null:
		p = self.get_current_player.call()
	Utils.log("Adding effect: " + str(e) + " for player " + str(p))
	self.effects[p].push_back(e)
	

func trigger(t : Effect.Trigger):
	var p = self.get_current_player.call()
	var duration_affected = self.effects[p].filter(func (e): return e.duration_trigger == t)
	var to_trigger = self.effects[p].filter(func (e): return e.active_trigger == t)
	for e in to_trigger:
		Utils.log("Triggering effect: " + str(e) + " for player " + str(p))
		self.apply_active.call(e)
	for e in duration_affected:
		e.duration -= 1
		if e.duration <= 0:
			self.effects[p].erase(e)
			Utils.log("Effect " + str(e) + " has expired for player " + str(p))

extends Node

var apply_active : Callable
var get_current_player : Callable

var effects: Dictionary = {}
var global_effects = []


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
	if e.type == Effect.Type.Active and e.active_trigger == Effect.Trigger.Instant:
		self.apply_active.call(e)
	else:
		self.effects[p].push_back(e)
	
func add_global(e : Effect):
	if e.type == Effect.Type.Active and e.active_trigger == Effect.Trigger.Instant:
		self.apply_active.call(e)
	else:
		self.global_effects.push_back(e)


func trigger(t: Effect.Trigger):
	var call_actives = func(arr):
		for e in arr:
			if e.active_trigger == t:
				Utils.log("Triggering effect: " + str(e))
				self.apply_active.call(e)
	var reduce_duration = func(arr):
		for e in arr:
			e.duration -= 1
			if e.duration <= 0:
				arr.erase(e)
				Utils.log("Effect " + str(e) + " has expired")
	Utils.log("Triggered: " + str(Effect.Trigger.keys()[t]))
	var p = self.get_current_player.call()

	var to_trigger = self.effects[p].filter(func (e): return e.active_trigger == t)
	call_actives.call(to_trigger)
	
	var to_trigger_global = self.global_effects.filter(func (e): return e.active_trigger == t)
	call_actives.call(to_trigger_global)

	var duration_affected = self.effects[p].filter(func (e): return e.duration_trigger == t)
	reduce_duration.call(duration_affected)

	var global_duration_affected = self.global_effects.filter(func (e): return e.duration_trigger == t)
	reduce_duration.call(global_duration_affected)
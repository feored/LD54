extends RefCounted
class_name Effect

enum Trigger {
	Instant,
	CardDrawn,
	CardPlayed,
	CardDiscarded,
	RegionGained,
	RegionLost,
	FaithGained,
	TurnOver
}
enum Type { Power, Action, Resource }

var duration: int
var duration_trigger: Trigger
var is_triggered: bool
var trigger: Trigger
var type: Type
var name: String
var value: Variant


func _to_string():
	return (
		"Effect [Type: "
		+ str(Effect.Type.keys()[self.type])
		+ " / Name: "
		+ self.name
		+ " / Value: "
		+ str(self.value)
		+ "/ Trigger: "
		+ str(Effect.Trigger.keys()[self.trigger])
		+ " / Is Triggered: "
		+ str(self.is_triggered)
		+ " / Duration: "
		+ str(self.duration)
		+ " / Duration Trigger: "
		+ str(Effect.Trigger.keys()[self.duration_trigger])
		+ "]"
	)


func string_to_type(s: String) -> Type:
	s = s.strip_edges()
	s = s.to_lower()
	if s == "power":
		return Type.Power
	elif s == "action":
		return Type.Action
	elif s == "resource":
		return Type.Resource
	else:
		Utils.log("ERROR - Unknown type: " + s)
		return Type.Power


func string_to_trigger(s: String) -> Trigger:
	s = s.strip_edges()
	s = s.to_lower()
	if s == "instant":
		return Trigger.Instant
	elif s == "card_drawn":
		return Trigger.CardDrawn
	elif s == "card_played":
		return Trigger.CardPlayed
	elif s == "card_discarded":
		return Trigger.CardDiscarded
	elif s == "region_gained":
		return Trigger.RegionGained
	elif s == "region_lost":
		return Trigger.RegionLost
	elif s == "faith_gained":
		return Trigger.FaithGained
	elif s == "turn_over":
		return Trigger.TurnOver
	else:
		Utils.log("ERROR - Unknown trigger: " + s)
		return Trigger.Instant


func _init(e):
	duration = 0 if not e.has("duration") else e["duration"]
	duration_trigger = (
		Trigger.Instant
		if not e.has("duration_trigger")
		else string_to_trigger(e["duration_trigger"])
	)
	is_triggered = false if not e.has("is_triggered") else e["is_triggered"]
	trigger = Trigger.Instant if not e.has("trigger") else string_to_trigger(e["trigger"])
	type = string_to_type(e["type"])
	name = e["name"]
	value = e["value"]

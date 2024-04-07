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
enum Type { Power, Active, Resource }

var duration: int
var duration_trigger: Trigger
var active_trigger: Trigger
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
		+ str(Effect.Trigger.keys()[self.active_trigger])
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
	elif s == "active":
		return Type.Active
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
	type = string_to_type(e["type"])
	active_trigger = (
		Trigger.Instant
		if (self.type != Type.Active or not e.has("active_trigger"))
		else string_to_trigger(e["active_trigger"])
	)
	name = e["name"]
	value = e["value"]

# Three types of effects: Power, Action, and Resource.
# Powers are things that require player interaction. They are limited to one per card.

# Actions are things that have an immediate effect but don't require player input. e.g drawing a card._add_constant_central_force

# Resources are passives.

# Powers can only be activated on playing the card. Resources don't have a trigger, they are always active. Actions are triggered by the action_trigger.
# Duration is the number of events an effect lasts for. duratrion_trigger is the event in question (turn over, carddrawn, etc)

extends RefCounted
class_name BaseBot

var team = 0
var personality: BotPersonality

func play_turn(_world):
	pass


func _init(init_team, init_personality):
	self.team = init_team
	self.personality = init_personality


func get_regions(world, filter_team):
	return world.regions.values().filter(func(r): return r.team == filter_team)


func get_available_regions(world):
	return self.get_regions(world, self.team).filter(func(r): return r.units > 1 and not r.used)



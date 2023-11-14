extends RefCounted
class_name BaseBot

var team = 0


func play_turn(_world):
	pass


func _init(init_team):
	self.team = init_team


func get_regions(world, filter_team):
	return world.regions.values().filter(func(r): return r.team == filter_team)


func get_available_regions(world):
	return self.get_regions(world, self.team).filter(func(r): return r.units > 1 and not r.used)

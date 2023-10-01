extends RefCounted
class_name BaseBot


var team = 0


func play_turn(_world, _regions_used):
	pass


func _init(init_team):
	self.team = init_team

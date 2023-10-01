extends RefCounted
class_name Action

var team: int = 0
var action: int = Constants.Action.NONE
var region_from: int = Constants.NO_REGION
var region_target: int = Constants.NO_REGION


func _init(
	init_team,
	init_action,
	init_region_from = Constants.NO_REGION,
	init_region_target = Constants.NO_REGION
):
	self.team = init_team
	self.action = init_action
	self.region_from = init_region_from
	self.region_target = init_region_target

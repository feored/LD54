extends RefCounted
class_name Action

var team: int = 0
var action: int = Constants.Action.NONE
var region_from: int = Constants.NO_REGION
var region_to: int = Constants.NO_REGION
var tile: Vector2i = Constants.NULL_COORDS


func _init(
	init_team,
	init_action,
	init_region_from = Constants.NO_REGION,
	init_region_to = Constants.NO_REGION,
	init_tile = Constants.NULL_COORDS
):
	self.team = init_team
	self.action = init_action
	self.region_from = init_region_from
	self.region_to = init_region_to
	self.tile = init_tile

extends RefCounted
class_name Action

var team: int = 0
var action: int = Constants.Action.None
var region_from: int = Constants.NULL_REGION
var region_to: int = Constants.NULL_REGION
var tiles: Array = []


func _init(
	init_team,
	init_action,
	init_region_from = Constants.NULL_REGION,
	init_region_to = Constants.NULL_REGION,
	init_tiles = []
):
	self.team = init_team
	self.action = init_action
	self.region_from = init_region_from
	self.region_to = init_region_to
	self.tiles = init_tiles


func _to_string():
	return (
		"Action: "
		+ Constants.TEAM_NAMES[self.team]
		+ " "
		+ Constants.Action.keys()[self.action]
		+ " From: "
		+ str(self.region_from)
		+ " To: "
		+ str(self.region_to)
	)

extends RefCounted
class_name Action

enum Type { None, Move, Sink, Emerge, Sacrifice, Reinforce, Build }

var team: int = 0
var action: int = Action.Type.None
var region_from: int = Constants.NULL_REGION
var region_to: int = Constants.NULL_REGION
var tiles: Array = []
var misc = null


func _init(
	init_team,
	init_action,
	init_region_from = Constants.NULL_REGION,
	init_region_to = Constants.NULL_REGION,
	init_tiles = [],
	init_misc = null
):
	self.team = init_team
	self.action = init_action
	self.region_from = init_region_from
	self.region_to = init_region_to
	self.tiles = init_tiles
	self.misc = init_misc


func clone():
	return Action.new(
		self.team, self.action, self.region_from, self.region_to, self.tiles, self.misc
	)


func _to_string():
	return (
		"Action: "
		+ Constants.TEAM_NAMES[self.team]
		+ " "
		+ Action.Type.keys()[self.action]
		+ " From: "
		+ str(self.region_from)
		+ " To: "
		+ str(self.region_to)
	)

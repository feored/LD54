extends RefCounted
class_name Action

var team: int = 0
var action: int = Constants.Action.NONE
var tile_from: Vector2i = Vector2i.ZERO
var tile_target: Vector2i = Vector2i.ZERO


func _init(team, action, tile_from = Vector2i.ZERO, tile_target = Vector2i.ZERO):
	self.team = team
	self.action = action
	self.tile_from = tile_from
	self.tile_target = tile_target

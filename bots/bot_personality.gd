extends RefCounted
class_name BotPersonality

var teams_alive: float = 0
var regions: float = 0
var tiles: float = 0
var units: float = 0
var landlocked: float = 0
var distance: float = 0

func _init(init_teams_alive, init_regions, init_tiles, init_units, init_landlocked, init_distance):
	self.teams_alive = init_teams_alive
	self.regions = init_regions
	self.tiles = init_tiles
	self.units = init_units
	self.landlocked = init_landlocked
	self.distance = init_distance


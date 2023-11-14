extends RefCounted
class_name WorldSim

var tiles: Dictionary = {}
var regions: Dictionary = {}
var resources : Dictionary = {}

func _init(world, res):
	for tile in world.tiles:
		self.tiles[tile.data.coords] = tile.data.duplicate()
	for region in world.regions:
		self.regions[region.data.id] = region.data.duplicate(true)
	for r in res.keys():
		self.resources[r] = res[r].duplicate()

func add_cell(cell):
	self.tiles[cell.data.coords] = cell.data.duplicate()

func remove_cell(cell_coords):
	var region_id = self.tiles[cell_coords].region
	self.tiles.erase(cell_coords)
	self.regions[region_id].tiles.erase(cell_coords)


func apply_action(action: Action):
	match action.action:
		Constants.Action.Move:
			await self.world.move_units(action.region_from, action.region_to, action.team)
		Constants.Action.Sacrifice:
			await self.world.sink_tiles(action.tiles)

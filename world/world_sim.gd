extends RefCounted
class_name WorldState

var regions: Dictionary = {}
var resources: Dictionary = {}
var adjacent_regions: Dictionary = {}


func clone():
	var cloned_world = WorldState.new()
	for r in self.regions.values():
		cloned_world.regions[r.id] = r.clone()
	## TODO CLONE RESOURCES
	return cloned_world


func _init(world = null):
	if world == null:
		return
	for region in world.regions.values():
		self.regions[region.data.id] = region.data.clone()
		self.adjacent_regions[region.data.id] = world.adjacent_regions(region.data.id)


func add_cell(cell):
	self.tiles[cell.data.coords] = cell.data.clone()


func remove_cell(cell_coords):
	var region_id = self.tiles[cell_coords].region
	self.regions[region_id].tiles.erase(cell_coords)


func simulate(action: Action):
	match action.action:
		Constants.Action.Move:
			self.move_units(action.region_from, action.region_to, action.team)
			return
		Constants.Action.Sacrifice:
			return


func move_units(region_from, region_to, team):
	var moved_units = self.regions[region_from].units - 1  #max(1, regions[region_from].units/2)
	self.regions[region_from].units -= moved_units
	self.regions[region_from].is_used = true

	if self.regions[region_from].team == self.regions[region_to].team:
		self.regions[region_to].units += moved_units
	else:
		if self.regions[region_to].units > moved_units:
			self.regions[region_to].units -= moved_units
		else:
			self.regions[region_to].units = moved_units - self.regions[region_to].units
			self.regions[region_to].team = team

extends Node
class_name Region


class RegionData:
	var id: int
	var team: int
	var tiles: Array
	var units: int

	func _init():
		self.id = Constants.NULL_REGION
		self.team = Constants.NULL_TEAM
		self.tiles = []
		self.units = 0

	func save():
		return {"id": self.id, "team": self.team, "tiles": self.tiles, "units": self.units}


var data: RegionData = RegionData.new()
var tiles_obj: Dictionary = {}
var label = null


func _init(init_id):
	self.data.id = init_id


func _ready():
	pass


func delete():
	for tile in self.tiles_obj.values():
		if tile != null:
			tile.queue_free()
	self.tiles_obj.clear()
	if label != null:
		self.label.queue_free()
	self.queue_free()


func sacrifice():
	var faith = self.data.units
	self.data.units = 0
	return faith


func delete_no_tiles():
	self.tiles_obj.clear()
	if label != null:
		self.label.queue_free()
	self.queue_free()


func update_display():
	self.label.set_text(str(self.data.units))


func set_team(init_team):
	self.data.team = init_team
	for tile in self.tiles_obj.values():
		tile.set_team(self.team)


func add_tile(coords, tileObj):
	tileObj.data.region = self.data.id
	self.data.tiles.append(coords)
	self.tiles_obj[coords] = tileObj


func remove_tile(coords):
	self.data.tiles.erase(coords)
	self.tiles_obj.erase(coords)


func random_in_region():
	return self.data.tiles[randi() % self.data.tiles.size()]


func generate_units():
	self.data.units += self.data.tiles.size()
	for tile in self.tiles_obj.values():
		if tile.data.building == Constants.Building.Barracks:
			self.data.units += Constants.BARRACKS_UNITS_PER_TURN
	update_display()


func set_units(init_units):
	self.data.units = init_units
	update_display()


func attack(num_attackers, team):
	var total_attackers = num_attackers
	for tile in self.tiles_obj.values():
		if tile.data.building == Constants.Building.Fort:
			total_attackers -= Constants.CASTLE_UNITS_REMOVED
	if total_attackers > self.data.units:
		self.data.units = total_attackers - self.data.units
		self.set_team(team)
	else:
		self.units -= total_attackers
	update_display()


func reinforce(num_reinforcements):
	self.data.units += num_reinforcements
	update_display()


func center_tile():
	var total = Vector2i(0, 0)
	for tile_obj in self.tiles_obj.values():
		total += tile_obj.data.coords
	var avg = Vector2(
		float(total.x) / self.tiles_obj.size(), float(total.y) / self.tiles_obj.size()
	)
	var closest_tile = self.tiles_obj.values()[0]
	var closest_distance = avg.distance_squared_to(closest_tile.data.coords)
	for t in self.tiles_obj.values():
		var distance = avg.distance_squared_to(t.data.coords)
		if distance < closest_distance:
			closest_tile = t
			closest_distance = distance
	return closest_tile.data.coords


func set_selected(show: bool):
	for t in self.tiles_obj.values():
		t.set_selected(show)


func set_used(is_used: bool):
	self.data.is_used = is_used
	for t in self.tiles_obj.values():
		t.set_barred(is_used)


func reset_tiles():
	self.data.tiles.clear()
	self.tiles_obj.clear()

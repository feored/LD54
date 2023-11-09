extends Node
class_name Region

var id: int = Constants.NULL_REGION
var team: int = Constants.NULL_TEAM
var is_used = false
var tiles: Dictionary = {}
var units = 0
var label = null


func _init(init_id):
	self.units = 0
	self.id = init_id


func _ready():
	self.units = 0


func delete():
	for tile in self.tiles.values():
		if tile != null:
			tile.queue_free()
	self.tiles.clear()
	if label != null:
		self.label.queue_free()
	self.queue_free()


func sacrifice():
	var faith = self.units - 1
	self.units = 1
	return faith


func delete_no_tiles():
	self.tiles.clear()
	if label != null:
		self.label.queue_free()
	self.queue_free()


func update_display():
	self.label.set_text(str(self.units))


func set_team(init_team):
	self.team = init_team
	for tile in tiles.values():
		tile.set_team(team)


func add_tile(coords, tileObj):
	tileObj.region = self.id
	self.tiles[coords] = tileObj


func random_in_region():
	return self.tiles.keys()[randi() % self.tiles.size()]


func generate_units():
	self.units += self.tiles.size()
	update_display()


func set_units(init_units):
	self.units = init_units
	update_display()


func center_tile():
	var total = Vector2i(0, 0)
	for tile_obj in self.tiles.values():
		total += tile_obj.coords
	var avg = Vector2(float(total.x) / self.tiles.size(), float(total.y) / self.tiles.size())
	var closest_tile = self.tiles.values()[0]
	var closest_distance = avg.distance_squared_to(closest_tile.coords)
	for t in self.tiles.values():
		var distance = avg.distance_squared_to(t.coords)
		if distance < closest_distance:
			closest_tile = t
			closest_distance = distance
	return closest_tile.coords


func set_selected(show: bool):
	for t in self.tiles.values():
		t.set_selected(show)


func set_used(is_used: bool):
	self.is_used = is_used
	for t in self.tiles.values():
		t.set_barred(is_used)


func reset_tiles():
	self.tiles.clear()


func get_save_data():
	var saved_state = {"id": self.id, "team": self.team, "tiles": [], "units": self.units}
	for coords in self.tiles:
		saved_state.tiles.append(var_to_str(coords))
	return saved_state

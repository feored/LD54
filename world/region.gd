extends Node
class_name Region

var id: int = Constants.NO_REGION
var team: int = Constants.NO_TEAM
var tiles: Dictionary = {}
var units = 0
var label = null


func _init(id):
	self.units = 0
	self.id = id


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


func update_display():
	self.label.set_text(str(self.units))


func set_team(team):
	self.team = team
	for tile in tiles.values():
		tile.set_team(team)


func add_tile(coords, tileObj):
	self.tiles[coords] = tileObj


func random_in_region():
	return self.tiles.keys()[randi() % self.tiles.size()]


func generate_units():
	self.units += self.tiles.size()
	update_display()


func set_units(units):
	self.units = units
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
	for t in self.tiles.values():
		t.set_barred(is_used)


func reset_tiles():
	self.tiles.clear()

func get_save_data():
	var saved_state = {
		"id": self.id,
		"team": self.team,
		"tiles": [],
		"units": self.units
	}
	for coords in self.tiles:
		saved_state.tiles.append(var_to_str(coords))
	return saved_state

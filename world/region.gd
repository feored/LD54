extends Node
class_name Region

var id: int = Constants.NO_REGION
var team: int = Constants.NO_TEAM
var tiles: Dictionary = {}
var units = 0
var label = null
var items: Dictionary = {}


func _init(id):
	self.id = id


func _ready():
	update_display()


func delete():
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
	var mod = 1
	if self.items.has(Constants.ItemEffectPhase.UNIT_GENERATION):
		mod = self.items[Constants.ItemEffectPhase.UNIT_GENERATION].modifier
	self.units += self.tiles.size() * mod
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

func update_items_durations():
	for effect in self.items:
		var item = self.items[effect]
		item.duration -=1
		if item.duration <= 0:
			print("Item with effect  ", effect ,"on region ", self.id, " expired.")
			self.items.erase(item)

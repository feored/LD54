extends Node
class_name Region

signal tile_added
signal tile_deleted
signal region_deleted

var tilePrefab = preload("res://world/tiles/tile.tscn")
var regionLabelPrefab = preload("res://world/regions/region_label.tscn")

var coords_to_pos: Callable
var get_contiguous_tilesets: Callable


class RegionData:
	var id: int
	var team: int
	var tiles: Array
	var units: int
	var is_used: bool

	func _init():
		self.id = Constants.NULL_REGION
		self.team = Constants.NULL_TEAM
		self.tiles = []
		self.units = 0
		self.is_used = false

	func save():
		return {"id": self.id, "team": self.team, "tiles": self.tiles, "units": self.units, "is_used": self.is_used}
	
	func _to_string():
		return "Region %s, team %s, %s tiles, %s units" % [str(self.id), str(self.team), str(self.tiles.size()), str(self.units)]


var data: RegionData = RegionData.new()
var tile_objs: Dictionary = {}
var label = null


func save():
	var base = self.data.save()
	var tile_dict = {}
	for tile in self.tile_objs.values():
		tile_dict[tile.data.coords] = tile.data.save()
	base.tiles = tile_dict
	return base


func init_from_save(saved_region):
	self.data.id = saved_region.id
	self.data.team = saved_region.team
	self.data.units = saved_region.units
	self.data.is_used = saved_region.is_used
	for tile in saved_region.tiles:
		spawn_cell(tile, saved_region.tiles[tile]["team"], saved_region.tiles[tile])
	self.label = regionLabelPrefab.instantiate()
	self.add_child(self.label)


func _init(init_id):
	self.data.id = init_id
	self.label = regionLabelPrefab.instantiate()
	self.add_child(self.label)

func _ready():
	pass


func delete():
	for tile in self.tile_objs.values():
		tile_deleted.emit(tile.data.coords, self.data.id, true)
		tile.queue_free()
	self.tile_objs.clear()
	self.data.tiles.clear()
	region_deleted.emit(self.data.id)
	if label != null:
		self.label.queue_free()
	self.queue_free()


func clear():
	# for t in self.tile_objs.values():
	# 	self.remove_child(t)
	self.tile_objs.clear()
	self.data.tiles.clear()



func sacrifice():
	var faith = self.data.units
	self.data.units = 0
	return faith


func update():
	print("Start update", self.data.id)
	print("Tiles:", self.data.tiles)
	if self.data.tiles.size() < 1:
		self.delete()
		return
	self.label.position = self.coords_to_pos.call(self.center_tile()) - self.label.size / 2  ## size of the label
	self.label.set_text(str(self.data.units))
	self.update_borders()


func set_team(init_team):
	self.data.team = init_team
	for tile in self.tile_objs.values():
		tile.set_team(self.data.team)


func add_tile(tileObj, should_reparent = false):
	tileObj.data.region = self.data.id
	var coords = tileObj.data.coords
	self.data.tiles.append(coords)
	self.tile_objs[coords] = tileObj
	if should_reparent:
		tileObj.reparent(self)
	else:
		self.add_child(tileObj)


func remove_tile(coords, delete_child = false):
	if coords not in self.data.tiles:
		print("Error: tile %s not in region" % str(coords))
		return
	if delete_child:
		self.remove_child(self.tile_objs[coords])
	self.data.tiles.erase(coords)
	self.tile_objs.erase(coords)
	


func random_in_region():
	return self.data.tiles[randi() % self.data.tiles.size()]


func generate_units():
	self.data.units += self.data.tiles.size()
	for tile in self.tile_objs.values():
		if tile.data.building == Constants.Building.Barracks:
			self.data.units += Constants.BARRACKS_UNITS_PER_TURN
	self.update()


func set_units(init_units):
	self.data.units = init_units
	self.update()


func attack(num_attackers, team):
	var total_attackers = num_attackers
	for tile in self.tile_objs.values():
		if tile.data.building == Constants.Building.Fort:
			total_attackers -= Constants.CASTLE_UNITS_REMOVED
	if total_attackers > self.data.units:
		self.data.units = total_attackers - self.data.units
		self.set_team(team)
	else:
		self.data.units -= total_attackers
	self.update()


func reinforce(num_reinforcements):
	self.data.units += num_reinforcements
	self.update()


func center_tile():
	var total = Vector2i(0, 0)
	for tile_obj in self.tile_objs.values():
		total += tile_obj.data.coords
	var avg = Vector2(
		float(total.x) / self.tile_objs.size(), float(total.y) / self.tile_objs.size()
	)
	var closest_tile = self.tile_objs.values()[0]
	var closest_distance = avg.distance_squared_to(closest_tile.data.coords)
	for t in self.tile_objs.values():
		var distance = avg.distance_squared_to(t.data.coords)
		if distance < closest_distance:
			closest_tile = t
			closest_distance = distance
	return closest_tile.data.coords


func set_selected(show: bool):
	for t in self.tile_objs.values():
		t.set_selected(show)


func set_used(is_used: bool):
	self.data.is_used = is_used
	for t in self.tile_objs.values():
		t.set_barred(is_used)


func spawn_cell(coords, team, save_data = {}):
	if self.data.tiles.has(coords):
		print("Error: cell already exists at " + str(coords))
		return
	var new_tile = tilePrefab.instantiate()
	new_tile.init_cell(coords, self.coords_to_pos.call(coords), team, self.data.id)
	new_tile.deleted.connect(delete_tile)
	self.data.tiles.append(coords)
	self.add_child(new_tile)
	if Settings.debug_position:
		var label = Label.new()
		label.text = str(coords)
		label.set_theme(load("res://assets/theme.tres"))
		label.position = -Vector2(12, 12)
		new_tile.add_child(label)
	self.tile_objs[coords] = new_tile
	if save_data.size() > 0:
		new_tile.init_from_save(save_data)
	tile_added.emit(new_tile)
	return new_tile


func delete_tile(coords):
	self.data.tiles.erase(coords)
	self.tile_objs.erase(coords)
	tile_deleted.emit(coords, self.data.id, false)
	self.update()


func sink_tile(coords):
	self.tile_objs[coords].sink()
	self.tile_objs.erase(coords)


func update_borders():
	for coords in self.data.tiles:
		for neighbor_direction in Constants.NEIGHBORS:
			var neighbor = Utils.get_neighbor_cell(coords, neighbor_direction)
			if self.data.tiles.has(neighbor):
				if self.tile_objs[coords].data.region != self.tile_objs[neighbor].data.region:
					self.tile_objs[coords].set_single_border(neighbor_direction, true)
				else:
					self.tile_objs[coords].set_single_border(neighbor_direction, false)
			else:
				self.tile_objs[coords].set_single_border(neighbor_direction, true)

extends Node2D
class_name Shape
const tile_prefab = preload("res://world/tiles/highlight/highlight.tscn")

var shape: Dictionary = {}
const HALF_TILE = Vector2(Constants.TILE_SIZE / 2, Constants.TILE_SIZE / 2)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# self.highlight(false)


func reroll():
	for tile in self.shape.values():
		tile.queue_free()
	self.shape.clear()
	self.init()


func init_with_coords(coords: Array):
	for coord in coords:
		var new_tile = tile_prefab.instantiate()
		self.add_child(new_tile)
		new_tile.position = Utils.to_global(Utils.map_to_local(coord)) - HALF_TILE
		self.shape[coord] = new_tile
		if Settings.debug_position:
			var label = Label.new()
			label.text = str(coord)
			label.position = -HALF_TILE
			new_tile.add_child(label)


func init():
	var available_tiles = [Vector2i(0, 0)]
	var used_tiles = []
	var to_add = 1 + Utils.rng.randi() % 5
	while to_add > 0:
		var random_tile = available_tiles[randi() % available_tiles.size()]
		available_tiles.erase(random_tile)
		used_tiles.append(random_tile)
		for i in Constants.NEIGHBORS:
			if (
				not available_tiles.has(Utils.get_neighbor_cell(random_tile, i))
				and not used_tiles.has(Utils.get_neighbor_cell(random_tile, i))
			):
				available_tiles.append(Utils.get_neighbor_cell(random_tile, i))
		var new_tile = tile_prefab.instantiate()
		self.add_child(new_tile)
		new_tile.position = Utils.to_global(Utils.map_to_local(random_tile)) - HALF_TILE
		if Settings.debug_position:
			var label = Label.new()
			label.text = str(random_tile)
			label.position = -HALF_TILE
			new_tile.add_child(label)
		self.shape[random_tile] = new_tile
		to_add -= 1


func highlight_center():
	self.shape[Vector2i(0, 0)].self_modulate = Color.hex(0xffffffff)


func try_place(pos: Vector2i, tiles: Array):
	var shape_coords = self.shape.keys().duplicate()
	for i in range(shape_coords.size()):
		if tiles.has(adjusted_coords(shape_coords[i], pos)):
			self.shape[shape_coords[i]].highlight(true)
		else:
			self.shape[shape_coords[i]].highlight(false)


func placeable(pos: Vector2i, tiles: Array):
	var shape_coords = self.shape.keys().duplicate()
	for i in range(shape_coords.size()):
		if not tiles.has(adjusted_coords(shape_coords[i], pos)):
			return false
	return true


func highlight(val: bool):
	for tile in self.shape.values():
		tile.highlight(val)


func adjusted_coords(coords: Vector2i, pos: Vector2i):
	### Specifically for stacked layout with horizontal offset,
	### see https://github.com/godotengine/godot/blob/master/scene/2d/tile_map.cpp#L3440
	var adjusted = coords + pos
	if coords.y % 2 != 0 and pos.y % 2 != 0:
		adjusted.x += 1
	return adjusted


func adjusted_shape_coords(pos: Vector2i):
	var shape_coords = self.shape.keys().duplicate()
	for i in range(shape_coords.size()):
		shape_coords[i] = adjusted_coords(shape_coords[i], pos)
	return shape_coords


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

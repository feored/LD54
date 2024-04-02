extends Node2D
class_name Shape
const tile_prefab = preload("res://world/tiles/highlight/highlight.tscn")

var coords: Dictionary = {}
const HALF_TILE = Vector2(Constants.TILE_SIZE / 2, Constants.TILE_SIZE / 2)

var COLOR_HIGHLIGHT = Color.hex(0xffffffff)
var COLOR_SINK = Color.hex(0xf53333ff)
var COLOR_EMERGE = Color.hex(0x32e680ff)
var COLOR_HIGHLIGHT_SINK = COLOR_SINK.lerp(COLOR_HIGHLIGHT, 0.5)
var COLOR_HIGHLIGHT_EMERGE = COLOR_EMERGE.lerp(COLOR_HIGHLIGHT, 0.5)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# self.highlight(false)


func reroll():
	for tile in self.coords.values():
		tile.queue_free()
	self.coords.clear()
	self.init()


func init_with_coords(init_coords: Array):
	for coord in init_coords:
		var new_tile = tile_prefab.instantiate()
		self.add_child(new_tile)
		new_tile.position = Utils.to_global(Utils.map_to_local(coord)) - HALF_TILE
		self.coords[coord] = new_tile
		if Constants.DEBUG_POSITION:
			var label = Label.new()
			label.text = str(coord)
			label.position = -HALF_TILE
			new_tile.add_child(label)


func init():
	roll_num(1 + Utils.rng.randi() % 5)


func roll_num(num: int):
	var available_tiles = [Vector2i(0, 0)]
	var used_tiles = []
	var to_add = num
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
		if Constants.DEBUG_POSITION:
			var label = Label.new()
			label.text = str(random_tile)
			label.position = -HALF_TILE
			new_tile.add_child(label)
		self.coords[random_tile] = new_tile
		to_add -= 1


func highlight_type(sink = Action.Type.Sink):
	for c in self.coords:
		if c == Vector2i(0, 0):
			if sink == Action.Type.Sink:
				self.coords[Vector2i(0, 0)].self_modulate = COLOR_HIGHLIGHT_SINK
			else:
				self.coords[Vector2i(0, 0)].self_modulate = COLOR_HIGHLIGHT_EMERGE
			continue
		if sink == Action.Type.Sink:
			self.coords[c].self_modulate = COLOR_SINK
		else:
			self.coords[c].self_modulate = COLOR_EMERGE


func try_place(pos: Vector2i, tiles: Array):
	var shape_coords = self.coords.keys()
	for i in range(shape_coords.size()):
		if tiles.has(adjusted_coords(shape_coords[i], pos)):
			self.coords[shape_coords[i]].highlight(true)
		else:
			self.coords[shape_coords[i]].highlight(false)


func try_emerge(pos: Vector2i, tiles: Array):
	var shape_coords = self.coords.keys()
	for i in range(shape_coords.size()):
		if tiles.has(adjusted_coords(shape_coords[i], pos)):
			self.coords[shape_coords[i]].highlight(false)
		else:
			self.coords[shape_coords[i]].highlight(true)


func placeable(pos: Vector2i, tiles: Array):
	var shape_coords = self.coords.keys().duplicate()
	for i in range(shape_coords.size()):
		if not tiles.has(adjusted_coords(shape_coords[i], pos)):
			return false
	return true


func emergeable(pos: Vector2i, tiles: Array):
	var shape_coords = self.coords.keys().duplicate()
	for i in range(shape_coords.size()):
		if tiles.has(adjusted_coords(shape_coords[i], pos)):
			return false
	return true


func highlight(val: bool):
	for tile in self.coords.values():
		tile.highlight(val)


func adjusted_coords(coords: Vector2i, pos: Vector2i):
	### Specifically for stacked layout with horizontal offset,
	### see https://github.com/godotengine/godot/blob/master/scene/2d/tile_map.cpp#L3440
	var adjusted = coords + pos
	if coords.y % 2 != 0 and pos.y % 2 != 0:
		adjusted.x += 1
	return adjusted


func adjusted_shape_coords(pos: Vector2i):
	var shape_coords = self.coords.keys().duplicate()
	for i in range(shape_coords.size()):
		shape_coords[i] = adjusted_coords(shape_coords[i], pos)
	return shape_coords


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

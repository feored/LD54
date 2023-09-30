extends TileMap

var tile = preload("res://world/tile.gd")

var tiles = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_cell(0, Vector2i(0, 0), 1, Vector2i(0, 0), 0)
	self.set_cell(0, Vector2i(1, -1), 2, Vector2i(0, 0), 0)
	# for i in range(-1, 1,):
	# 	for j in range(-1, 1):
	# 		var new_tile = tile.new()
	# 		self.set_cell(0, Vector2i(i, j), new_tile.tile_type, Vector2i(0,0), 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

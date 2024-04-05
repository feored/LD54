extends RefCounted
class_name Map

const START = Vector2i(-1, -999)

enum Location {
	Map,
	Event
}
	

class Island:
	var location : Location
	var visited: bool = false
	var next : Array
	var info : Dictionary
	
	func _init():
		self.location = Location.Map
		self.visited = false
		self.next = []

const MAP_WIDTH = 7
const MAP_HEIGHT = 10
const MAP_PATHS = 6

var map : Dictionary

func get_entrances():
	return map.keys().filter(func (k): return k.x == 0)

func layout_to_map (layout):
	var new_map : Dictionary = {}
	for coords in layout:
		var island = Island.new()
		island.location = Location.Map if Utils.rng.randi()%2 == 0 else Location.Event
		if island.location == Location.Map:
			island.info["path"] = Constants.SCENARIOS[Utils.rng.randi()%Constants.SCENARIOS.size()].path
		else:
			island.info["event"] = Constants.EVENTS.keys()[Utils.rng.randi()%Constants.EVENTS.keys().size()]
		island.next = layout[coords]
		new_map[coords] = island
	return new_map


func gen_layout():
	var try_map = {}
	for i in range(MAP_PATHS):
		var current_x = Utils.rng.randi()%MAP_WIDTH
		for j in range(1, MAP_HEIGHT):
			## don't cross paths
			var possible = [current_x]
			if current_x > 0 and (!try_map.has(Vector2i(j-1, current_x-1)) or Vector2i(j, current_x) not in try_map[Vector2i(j-1, current_x-1)]):
				possible.append(current_x-1)
			if current_x < MAP_WIDTH-1 and (!try_map.has(Vector2i(j-1, current_x+1)) or Vector2i(j, current_x) not in try_map[Vector2i(j-1, current_x+1)]):
				possible.append(current_x+1)
			var next_x = possible[Utils.rng.randi()%possible.size()]
			if !try_map.has(Vector2i(j-1, current_x)):
				try_map[Vector2i(j-1, current_x)] = [Vector2i(j, next_x)]
			else:
				try_map[Vector2i(j-1, current_x)].append(Vector2i(j, next_x))
			current_x = next_x
		## add last row to the graph
		if !try_map.has(Vector2i(MAP_HEIGHT-1, current_x)):
			try_map[Vector2i(MAP_HEIGHT-1, current_x)] = []
	return try_map

func _init():
	var layout = self.gen_layout()
	print_layout(layout)
	self.map = self.layout_to_map(layout)

func print_layout(try_map):
	var map_floors = []
	for i in range(MAP_HEIGHT):
		var map_floor = ""
		for j in range(MAP_WIDTH):
			map_floor += " x " if try_map.has(Vector2i(i, j)) else "   "
		map_floors.push_back(map_floor)
		var map_paths = ""
		for j in range(MAP_WIDTH):
			if try_map.has(Vector2i(i, j)):
				if try_map.has(Vector2i(i+1, j-1)) and try_map[Vector2i(i, j)].has(Vector2i(i+1, j-1)):
					map_paths += "\\"
				else:
					map_paths += " "
				if try_map.has(Vector2i(i+1, j)) and try_map[Vector2i(i, j)].has(Vector2i(i+1, j)):
					map_paths += "|"
				else:
					map_paths += " "
				if try_map.has(Vector2i(i+1, j+1)) and try_map[Vector2i(i, j)].has(Vector2i(i+1, j+1)):
					map_paths += "/"
				else:
					map_paths += " "
			else:
				map_paths += "   "
		map_floors.push_back(map_paths)
	
	for i in range(map_floors.size()):
		print(map_floors[map_floors.size()-i-1])

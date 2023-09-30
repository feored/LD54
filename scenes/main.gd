extends Node2D

@onready var world = $"%World"
@onready var coordsLabel = $"%Coordinates"
@onready var unitsLabel = $"%Units"
@onready var teamLabel = $"%TeamLabel"
@onready var turnLabel = $"%TurnLabel"

var clicked_tile = null
var turn = 0;
var teams = [1, 2, 3];
var inspect_mode = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# var new_tile = tile.new(global_pos_to_coords(event.position), 1)
			# self.update_cell(new_tile)
			var coords_clicked = world.global_pos_to_coords(event.position)
			if world.tiles.has(coords_clicked):
				on_tile_clicked(world.tiles[coords_clicked])
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# var new_tile = tile.new(global_pos_to_coords(event.position), 1, 0)
			world.set_cell(1, world.global_pos_to_coords(event.position), -1, Vector2i(0,0), 0)
			# self.update_cell(new_tile)

func _on_turn_button_pressed():
	next_turn()
	generate_units(self.teams[self.turn])
	update_display()
	world.generate_disaster()

func _on_inspect_button_toggled(pressed: bool):
	inspect_mode = pressed;

func on_tile_clicked(new_clicked_tile):
	if (inspect_mode):
		clicked_tile = new_clicked_tile;
		update_display()
		return
	var current_team = self.teams[self.turn]
	if (clicked_tile != null and clicked_tile.team == current_team):
		if (new_clicked_tile.team == current_team):
			if (clicked_tile.units > 1):
				new_clicked_tile.set_units(new_clicked_tile.units +  clicked_tile.units -1)
				clicked_tile.set_units(1)
			else:
				print("Error: cannot reinforce " + str(new_clicked_tile.coords) + "(" + str(new_clicked_tile.units) + 
				"units). Not enough units currently selected on " + str(clicked_tile.coords) + "( " + str(clicked_tile.units) + " units).")
		else:
			if (new_clicked_tile.units >= clicked_tile.units - 1): # 1 unit always needs to stay and defend
				print("Error: cannot attack " + str(new_clicked_tile.coords) + "(" + str(new_clicked_tile.units) + 
				"units). Not enough units currently selected on " + str(clicked_tile.coords) + "( " + str(clicked_tile.units) + " units).")
			else:
				new_clicked_tile.set_team(current_team)
				new_clicked_tile.set_units(clicked_tile.units - new_clicked_tile.units - 1)
				clicked_tile.set_units(1)
	clicked_tile = new_clicked_tile
	update_display()


func update_display():
	if (clicked_tile != null):
		coordsLabel.text = str(clicked_tile.coords)
		unitsLabel.text = str(clicked_tile.units)
		teamLabel.text = str(clicked_tile.team)
	turnLabel.text = str(self.teams[self.turn])

func next_turn():
	self.turn = (self.turn + 1) % (self.teams.size())
	while (!tiles_left(self.teams[turn])):
		self.turn = (self.turn + 1) % (self.teams.size())

func tiles_left(team):
	for coord in world.tiles:
		if (world.tiles[coord].team == team):
			return true
	return false

func generate_units(team):
	for tile in world.tiles:
		if world.tiles[tile].team == team:
			world.tiles[tile].set_units(world.tiles[tile].units + 1)

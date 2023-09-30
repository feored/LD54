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

var actions_history = []
var bots = []

# Called when the node enters the scene tree for the first time.
func _ready():
	self.world.init_world()
	for i in range(1,4):
		self.bots.append(DumbBot.new(i))
		self.world.add_team(i)


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
	
	bots_play()
	await get_tree().create_timer(Constants.TURN_TIME).timeout
	generate_units(self.teams[self.turn])
	update_display()
	world.generate_disaster()

func bots_play():
	var bot_action = self.bots[self.turn].play_turn(self.world)
	apply_action(bot_action)
	self.actions_history.append(bot_action)

func _on_inspect_button_toggled(pressed: bool):
	inspect_mode = pressed;

func on_tile_clicked(new_clicked_tile):
	if (inspect_mode):
		clicked_tile = new_clicked_tile;
		update_display()
		return
	var current_team = self.teams[self.turn]
	if (clicked_tile != null and clicked_tile.team == current_team):
		self.world.move_units(clicked_tile, new_clicked_tile)
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
	

func tiles_left(team):
	for coord in world.tiles:
		if (world.tiles[coord].team == team):
			return true
	return false

func generate_units(team):
	for tile in world.tiles:
		if world.tiles[tile].team == team:
			world.tiles[tile].set_units(world.tiles[tile].units + 1)


func apply_action(action : Action):
	if action.action == Constants.Action.NONE:
		return
	if action.action == Constants.Action.MOVE:
		self.world.move_units(action.tile_from, action.tile_target)

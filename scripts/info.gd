extends Node

var run: Run
var current_map = null
var current_mods = []
var lost: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_map(map_path):
	var save_game = FileAccess.open("res://maps/" + map_path, FileAccess.READ)
	Utils.log("Loading map: " + map_path)
	var saved_state = JSON.parse_string(save_game.get_line())
	save_game.close()
	self.current_map = saved_state

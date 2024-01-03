extends Node2D

@onready var scenario_number = %ScenarioNumber
@onready var scenario_title = %ScenarioTitle
@onready var scenario_description = %ScenarioDescription
@onready var scenario_container = %ScenarioContainer
@onready var picker_container = %PickerContainer
@onready var world = $"World"
var current_scenario_id = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.input_locked = false
	Settings.skipping = false
	var offset_y = picker_container.size.y
	var offset_x = scenario_container.size.x/2
	self.world.camera.position += Vector2(offset_x, offset_y)
	self.world.init(func(): pass)
	self.load_scenario()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_scenario():
	var save_game = FileAccess.open("res://maps/" + Constants.scenarios[current_scenario_id].path, FileAccess.READ)
	var saved_state = JSON.parse_string(save_game.get_line())
	save_game.close()
	Settings.current_map = saved_state
	self.world.clear_island()
	self.world.load_regions(saved_state["regions"])
	self.scenario_number.text = "[" + str(current_scenario_id + 1) + "]"
	self.scenario_title.text = Constants.scenarios[current_scenario_id].title
	self.scenario_description.text = Constants.scenarios[current_scenario_id].description


func _on_left_button_pressed():
	self.current_scenario_id = (self.current_scenario_id - 1) % Constants.scenarios.size()
	self.world.animation_player.play("float_right")
	await self.world.animation_player.animation_finished
	self.load_scenario()
	self.world.animation_player.play("float_from_left")
	await self.world.animation_player.animation_finished
	

func _on_right_button_pressed():
	self.current_scenario_id = (self.current_scenario_id + 1) % Constants.scenarios.size()
	self.world.animation_player.play("float_left")
	await self.world.animation_player.animation_finished
	self.load_scenario()
	self.world.animation_player.play("float_from_right")
	await self.world.animation_player.animation_finished


func _on_play_button_pressed():
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_GAME)

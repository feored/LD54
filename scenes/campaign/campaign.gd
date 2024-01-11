extends Node2D

@onready var scenario_description = %ScenarioDescription
@onready var scenario_container = %ScenarioContainer
@onready var other_scenarios = %OtherScenarios
@onready var world = $"World"

const scenarios_button_group = preload("res://scenes/campaign/scenarios_button_group.tres")

var old_scenario_id = 0
var scenario_buttons = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.input_locked = false
	Settings.skipping = false
	var offset_y = 0
	var offset_x = scenario_container.size.x/2
	self.world.camera.position += Vector2(offset_x, offset_y)
	self.world.init(func(): pass)

	self.load_scenario(0)

	for i in range(Constants.scenarios.size()):
		var s = Constants.scenarios[i]
		var b = Button.new()
		b.text = "[%s] %s" % [i+1, s.title]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.toggle_mode = true
		b.button_group = self.scenarios_button_group
		b.pressed.connect(func(): self.switch_scenario(i))
		self.scenario_buttons[i] = b
		self.other_scenarios.add_child(b)
	self.scenario_buttons[0].button_pressed = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_scenario(scenario_id):
	var save_game = FileAccess.open("res://maps/" + Constants.scenarios[scenario_id].path, FileAccess.READ)
	var saved_state = JSON.parse_string(save_game.get_line())
	save_game.close()
	Settings.current_map = saved_state
	self.world.clear_island()
	self.world.load_regions(saved_state["regions"])
	self.scenario_description.text = Constants.scenarios[scenario_id].description
	self.old_scenario_id = scenario_id


func switch_scenario(scenario_id):
	var animations = ["float_right", "float_from_left"] if scenario_id < old_scenario_id else ["float_left", "float_from_right"]
	self.world.animation_player.play(animations[0])
	await self.world.animation_player.animation_finished
	self.load_scenario(scenario_id)
	self.world.animation_player.play(animations[1])
	await self.world.animation_player.animation_finished
	


func _on_play_button_pressed():
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_GAME)

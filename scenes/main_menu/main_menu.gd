extends Node2D


var scenarioPrefab = preload("res://ui/scenario/scenario.tscn")

@onready var world = $World
@onready var allScenarios = $"%AllScenarios"
@onready var buttonContainer = $"%ButtonContainer"
@onready var scenariosContainer = $"%ScenariosContainer"
@onready var returnButton =	$"%ReturnButton"
@onready var settingsContainer = $"%SettingsContainer"
@onready var logo = $"%Logo"

enum State{
	Main,
	Scenario,
	Settings
}

var elapsed = 0

func _ready():
	self.show_state(State.Main)
	Music.play_track(Music.Track.Menu)
	Sfx.disable_track(Sfx.Track.Boom)

	self.world.init(Callable(self, "no_message"))
#	self.world.regionLabelsParent.hide()
	self.world.camera.active = false
	self.world.clear_island()
	self.world.generate_island()
	self.world.world_ready.connect(Callable(self, "sink"))

	settingsContainer.disappear = func():
		self.show_state(State.Main)

	for scenario in Constants.scenarios:
		var scenario_obj = scenarioPrefab.instantiate()
		scenario_obj.init(scenario)
		allScenarios.add_child(scenario_obj)

func no_message(_message):
	pass

func show_state(state):
	match state:
		State.Main:
			self.buttonContainer.show()
			self.scenariosContainer.hide()
			self.returnButton.hide()
			self.settingsContainer.hide()
			self.logo.show()
		State.Scenario:
			self.buttonContainer.hide()
			self.scenariosContainer.show()
			self.returnButton.show()
			self.settingsContainer.hide()
			self.logo.hide()
		State.Settings:
			self.buttonContainer.hide()
			self.scenariosContainer.hide()
			self.returnButton.hide()
			self.settingsContainer.show()
			self.logo.hide()


func sink(_coords = Vector2.ZERO):
	var tile_to_sink = Utils.pick_tile_to_sink(self.world.tiles.keys())
	self.world.tiles[tile_to_sink].deleted.connect(Callable(self, "sink"))
	self.world.sink_tiles([tile_to_sink])

func _process(_delta):
	pass

func _on_play_btn_pressed():
	await SceneTransition.change_scene(SceneTransition.SCENE_MAP_GENERATOR)


func _on_play_scenario_btn_pressed():
	self.show_state(State.Scenario)


func _on_return_button_pressed():
	self.show_state(State.Main)


func _on_settings_btn_pressed():
	show_state(State.Settings)


func _on_quit_button_pressed():
	get_tree().quit()



func _on_map_editor_btn_pressed():
	await SceneTransition.change_scene(SceneTransition.SCENE_MAP_EDITOR)

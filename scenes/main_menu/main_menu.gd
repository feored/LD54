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

	self.world.init(Callable(self, "no_message"))
	self.world.regionLabelsParent.hide()
	self.world.camera.active = false
	self.world.clear_island()
	self.world.generate_island()

	settingsContainer.disappear = func():
		self.show_state(State.Main)

	for scenario in Constants.scenarios:
		var scenario_obj = scenarioPrefab.instantiate()
		scenario_obj.init(scenario)
		allScenarios.add_child(scenario_obj)
	await sink()

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


func sink():
	while self.world.tiles.size() > 0:
		await self.world.sink_tiles([Utils.pick_tile_to_sink(self.world.tiles.keys())])
		await Utils.wait(Constants.MENU_WAIT_TIME)

func _process(_delta):
	pass

func _on_play_btn_pressed():
	Settings.game_mode = Constants.GameMode.Play
	await SceneTransition.change_scene("res://scenes/main/main.tscn")


func _on_play_scenario_btn_pressed():
	self.show_state(State.Scenario)


func _on_return_button_pressed():
	self.show_state(State.Main)


func _on_settings_btn_pressed():
	show_state(State.Settings)

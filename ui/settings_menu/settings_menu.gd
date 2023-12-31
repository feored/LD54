extends Control

@onready var full_screen_button: Button = $"%FullScreenButton"
@onready var master_volume_slider: HSlider = $"%MasterVolumeSlider"
@onready var music_volume_slider: HSlider = $"%MusicVolumeSlider"
@onready var sfx_volume_slider: HSlider = $"%SFXVolumeSlider"

var disappear = null

# Called when the node enters the scene tree for the first time.
func _ready():
	full_screen_button.button_pressed = Settings.get_setting(Settings.Setting.FullScreen)
	master_volume_slider.value = Settings.get_setting(Settings.Setting.MasterVolume)
	music_volume_slider.value = Settings.get_setting(Settings.Setting.MusicVolume)
	sfx_volume_slider.value = Settings.get_setting(Settings.Setting.SfxVolume)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_full_screen_button_toggled(button_pressed:bool):
	Settings.set_setting(Settings.Setting.FullScreen, button_pressed)
	Settings.apply_config()

func _on_sfx_volume_slider_value_changed(value:float):
	Settings.set_setting(Settings.Setting.SfxVolume, value)
	Settings.apply_config()

func _on_music_volume_slider_value_changed(value:float):
	Settings.set_setting(Settings.Setting.MusicVolume, value)
	Settings.apply_config()

func _on_master_volume_slider_value_changed(value:float):
	Settings.set_setting(Settings.Setting.MasterVolume, value)
	Settings.apply_config()


func _on_settings_return_button_pressed():
	disappear.call()

extends Control

@onready var full_screen_button: Button = $"%FullScreenButton"
@onready var master_volume_slider: HSlider = $"%MasterVolumeSlider"
@onready var music_volume_slider: HSlider = $"%MusicVolumeSlider"
@onready var sfx_volume_slider: HSlider = $"%SFXVolumeSlider"
@onready var auto_camera_focus_button : Button = $"%AutoCameraFocusButton"

var disappear = null

# Called when the node enters the scene tree for the first time.
func _ready():
	full_screen_button.button_pressed = Settings.get_setting(Settings.Setting.FullScreen)
	master_volume_slider.value = Settings.get_setting(Settings.Setting.MasterVolume)
	music_volume_slider.value = Settings.get_setting(Settings.Setting.MusicVolume)
	sfx_volume_slider.value = Settings.get_setting(Settings.Setting.SfxVolume)
	auto_camera_focus_button.button_pressed = Settings.get_setting(Settings.Setting.AutoCameraFocus)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_full_screen_button_toggled(button_pressed:bool):
	Settings.set_setting(Settings.Setting.FullScreen, button_pressed)
	Settings.apply_fullscreen()

func _on_sfx_volume_slider_value_changed(value:float):
	Settings.set_setting(Settings.Setting.SfxVolume, value)
	Settings.apply_volume_sfx()

func _on_music_volume_slider_value_changed(value:float):
	Settings.set_setting(Settings.Setting.MusicVolume, value)
	Settings.apply_volume_music()

func _on_master_volume_slider_value_changed(value:float):
	Settings.set_setting(Settings.Setting.MasterVolume, value)
	Settings.apply_volume_master()

func _on_auto_camera_focus_button_toggled(button_pressed):
	Settings.set_setting(Settings.Setting.AutoCameraFocus, button_pressed)

func _on_settings_return_button_pressed():
	disappear.call()



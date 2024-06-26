extends Node

enum Setting { FullScreen, MasterVolume, MusicVolume, SfxVolume, InstantMap, AutoCameraFocus }
const SETTING_NAMES = {
	Setting.FullScreen: "full_screen",
	Setting.MasterVolume: "master_volume",
	Setting.MusicVolume: "music_volume",
	Setting.SfxVolume: "sfx_volume",
	Setting.InstantMap : "instant_map",
	Setting.AutoCameraFocus : "auto_camera_focus"
}

const DEFAULT_SECTION = "settings"
const DEFAULT_PATH = "user://config.cfg"
const DEFAULT_CONFIG = {
	Setting.FullScreen: false,
	Setting.MasterVolume: 1,
	Setting.MusicVolume: 1,
	Setting.SfxVolume: 1,
	Setting.InstantMap: true,
	Setting.AutoCameraFocus: true
}

@onready var audio_bus = {
	"Master": AudioServer.get_bus_index("Master"),
	"Music": AudioServer.get_bus_index("Music"),
	"SFX": AudioServer.get_bus_index("SFX"),
}

var settings = null
var input_locked: bool = false
var turn_time = Constants.TURN_TIME
var skipping = false
var editor_tile_distinct_mode = false


func _ready():
	self.settings = await load_config()
	await apply_config()

func load_config():
	if settings != null:
		Utils.log("Tried to load config more than once.")
		return
	var config = ConfigFile.new()
	var err = config.load(DEFAULT_PATH)
	# If the file didn't load, ignore it.
	if err != OK:
		for setting in DEFAULT_CONFIG:
			config.set_value(DEFAULT_SECTION, SETTING_NAMES[setting], DEFAULT_CONFIG[setting])
	# If the file did load, but is missing some settings, add them.
	else:
		for setting in DEFAULT_CONFIG:
			if not config.has_section_key(DEFAULT_SECTION, SETTING_NAMES[setting]):
				config.set_value(DEFAULT_SECTION, SETTING_NAMES[setting], DEFAULT_CONFIG[setting])
	return config

func save_config():
	assert(self.settings != null, "Tried to save config before config was loaded.")
	var err = self.settings.save(DEFAULT_PATH)
	if err != OK:
		Utils.log("Failed to save config file.")

func get_setting(setting: Setting):
	assert(self.settings != null, "Tried to get setting before config was loaded.")
	return get_config_setting(setting, settings)

func get_config_setting(setting: Setting, config: ConfigFile):
	return config.get_value(DEFAULT_SECTION, SETTING_NAMES[setting])

func set_setting(setting: Setting, value):
	assert(self.settings != null, "Tried to set setting before config was loaded.")
	self.settings.set_value(DEFAULT_SECTION, SETTING_NAMES[setting], value)
	save_config()


func apply_config():
	apply_fullscreen()
	apply_volume_master()
	apply_volume_music()
	apply_volume_sfx()

func skip(val: bool):
	self.turn_time = 0.0 if val else Constants.TURN_TIME
	skipping = val

func change_volume(bus_name, new_volume):
	var db_volume =  linear_to_db(new_volume)
	AudioServer.set_bus_volume_db(audio_bus[bus_name], db_volume)

func apply_volume_master():
	change_volume("Master", get_config_setting(Setting.MasterVolume, self.settings))

func apply_volume_music():
	change_volume("Music", get_config_setting(Setting.MusicVolume, self.settings))

func apply_volume_sfx():
	change_volume("SFX", get_config_setting(Setting.SfxVolume, self.settings))
	
func apply_fullscreen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if get_config_setting(Setting.FullScreen, self.settings) else DisplayServer.WINDOW_MODE_WINDOWED)

extends Node2D

const LOWEST_VOLUME = -80

enum Track { Boom, Click, Enter, Select, Cancel, Hover }

const TRACKS = {
	Track.Boom: preload("res://assets/sfx/Explosion5.wav"),
	Track.Click: preload("res://assets/sfx/click_02.wav"),
	Track.Enter: preload("res://assets/sfx/enter_13.wav"),
	Track.Select: preload("res://assets/sfx/click_02.wav"),
	Track.Cancel: preload("res://assets/sfx/click_04.wav"),
	Track.Hover: preload("res://assets/sfx/click_06.wav"),
}

const CUSTOM_VOLUME = {
	Track.Boom: -12,
	Track.Hover: -10,
	Track.Click: -6
}

const CUSTOM_POLYPHONY = {
	Track.Boom: 1,
}

var players = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	connect_buttons(get_tree().root)
	get_tree().connect("node_added", Callable(self, "_on_SceneTree_node_added"))
	for key in TRACKS:
		var player = AudioStreamPlayer.new()
		player.stream = TRACKS[key]
		player.max_polyphony = 10 if key not in CUSTOM_POLYPHONY else CUSTOM_POLYPHONY[key]
		player.bus = "SFX"
		if key in CUSTOM_VOLUME:
			player.volume_db = CUSTOM_VOLUME[key]
		self.add_child(player)
		self.players[key] = player


func play(track: Track):
	self.players[track].play()

func disable_track(track: Track):
	self.players[track].volume_db = LOWEST_VOLUME

func enable_track(track: Track):
	self.players[track].volume_db = 0


func _on_SceneTree_node_added(node):
	if node is Button:
		connect_to_button(node)


func _on_Button_pressed():
	self.play(Track.Click)


func on_Button_hovered():
	self.play(Track.Hover)


# recursively connect all buttons
func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)


func connect_to_button(button):
	button.connect("pressed", Callable(self, "_on_Button_pressed"))
	button.connect("mouse_entered", Callable(self, "on_Button_hovered"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

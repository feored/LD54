extends CanvasLayer

@onready var esc_menu = $"%EscMenu"
@onready var settings_menu = $"%SettingsMenu"

enum State {Esc, Settings}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	show_state(State.Esc)
	settings_menu.disappear = func(): show_state(State.Esc)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func show_state(state):
	match state:
		State.Esc:
			esc_menu.show()
			settings_menu.hide()
		State.Settings:
			esc_menu.hide()
			settings_menu.show()
		_:
			print("Error: Invalid state")

func _on_menu_button_pressed():
	get_tree().paused = false
	await SceneTransition.change_scene("res://scenes/main_menu/main_menu.tscn")


func _on_resume_button_pressed():
	self.delete()


func delete():
	get_tree().paused = false
	self.queue_free()


func _unhandled_input(event):
	if event.is_action_pressed("escmenu"):
		self.delete()

func _on_settings_button_pressed():
	self.show_state(State.Settings)

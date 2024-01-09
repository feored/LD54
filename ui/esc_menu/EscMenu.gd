extends CanvasLayer

enum State {Esc, Settings}

@onready var esc_menu = $"%EscMenu"
@onready var settings_menu = $"%SettingsMenu"
@onready var esc_panel = %EscPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	self.esc_panel.hide()
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
			Utils.log("Error: Invalid state")

func _on_menu_button_pressed():
	get_tree().paused = false
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_MENU)

func _on_resume_button_pressed():
	self.disappear()

func appear():
	show_state(State.Esc)
	self.get_tree().paused = true
	self.esc_panel.show()

func disappear():
	self.get_tree().paused = false
	self.esc_panel.hide()

func _unhandled_input(event):
	if event.is_action_pressed("escmenu"):
		self.disappear() if self.esc_panel.visible else self.appear()

func _on_settings_button_pressed():
	self.show_state(State.Settings)


func _on_esc_button_pressed():
	self.appear()

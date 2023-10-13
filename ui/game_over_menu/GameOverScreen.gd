extends CanvasLayer

@onready var victoryLabel = $"%SuccessLabel"
@onready var taglineLabel = $"%SuccessTaglineLabel"
@onready var spectateBtn = $"%Spectate"

var is_victory = false
var parent = null
var is_spectate_possible = false


# Called when the node enters the scene tree for the first time.
func _ready():
	self.display_victory()
	get_tree().paused = true

func init(won_game: bool, game, spectate_possible):
	is_victory = won_game
	parent = game
	is_spectate_possible = spectate_possible

func display_victory():
	spectateBtn.visible = is_spectate_possible
	if is_victory:
		victoryLabel.text = "Victory!"
		taglineLabel.text = "Neptune is pleased with you."
		victoryLabel.self_modulate = Color.hex(0xb5ebf7ff)
	else:
		victoryLabel.text = "Defeat!"
		taglineLabel.text = "Neptune loses interest in you."
		victoryLabel.self_modulate = Color.hex(0xd46666ff)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_spectate_pressed():
	parent.spectating = true
	get_tree().paused = false
	self.queue_free()

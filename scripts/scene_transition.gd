extends CanvasLayer

const SCENE_MAIN_GAME = "res://scenes/main/main.tscn"
const SCENE_MAIN_MENU = "res://scenes/main_menu/main_menu.tscn"
const SCENE_MAP_GENERATOR = "res://scenes/map_generator/map_generator.tscn"
const SCENE_MAP_EDITOR = "res://scenes/map_editor/map_editor.tscn"
const SCENE_CAMPAIGN = "res://scenes/campaign/campaign.tscn"

@onready var animation_player = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_scene(target: String) -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	animation_player.play("fade_in")
	await animation_player.animation_finished
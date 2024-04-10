extends CanvasLayer

const SCENE_MAIN_GAME = "res://scenes/main/main.tscn"
const SCENE_MAIN_MENU = "res://scenes/main_menu/main_menu.tscn"
const SCENE_MAP_GENERATOR = "res://scenes/map_generator/map_generator.tscn"
const SCENE_MAP_EDITOR = "res://scenes/map_editor/map_editor.tscn"
const SCENE_CAMPAIGN = "res://scenes/campaign/campaign.tscn"
const SCENE_OVERWORLD = "res://scenes/overworld/overworld.tscn"
const SCENE_END = "res://scenes/end/end_game.tscn"
const SCENE_REWARD = "res://scenes/run_reward/run_reward.tscn"

@onready var animation_player = $AnimationPlayer

func change_scene(target: String) -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	animation_player.play_backwards("fade_out")
	await animation_player.animation_finished
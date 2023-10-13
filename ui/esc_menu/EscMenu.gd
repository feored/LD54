extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_resume_button_pressed():
	self.delete()


func delete():
	get_tree().paused = false
	self.queue_free()


func _unhandled_input(event):
	if event.is_action_pressed("escmenu"):
		self.delete()

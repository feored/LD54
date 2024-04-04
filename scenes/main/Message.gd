extends Label

var tween = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_message(text):
	if self.tween != null:
		self.tween.kill()
	self.set_text(text)
	self.modulate = Color.WHITE
	self.tween = self.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	self.tween.tween_property(self, "modulate", Color.TRANSPARENT, 5)

extends Panel
signal card_picked(card)

@onready var grid = %CardGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(cards):
	for c in grid.get_children():
		c.queue_free()
	grid.size = Vector2.ZERO
	for c in cards:
		c.picked.connect(func(): grid.remove_child(c); self.card_picked.emit(c))
		grid.add_child(c)
	self.show()


func _on_skip_button_pressed():
	self.card_picked.emit(null)

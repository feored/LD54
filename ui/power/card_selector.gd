extends Panel
signal cards_picked(cards)

@onready var grid = %CardGrid
@onready var label = %Label

var to_pick = 1
var cards = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(init_cards, init_nb):
	for c in grid.get_children():
		c.queue_free()
	self.cards.clear()
	label.text = "Select " + str(init_nb) + " card(s) to add to your deck."
	self.to_pick = init_nb
	grid.size = Vector2.ZERO
	for c in init_cards:
		c.picked.connect(func(): _on_card_picked(c))
		grid.add_child(c)
	self.show()

func _on_card_picked(c):
	self.cards.append(c)
	self.grid.remove_child(c)
	if self.cards.size() == self.to_pick:
		self.hide()
		self.cards_picked.emit(self.cards)


func _on_skip_button_pressed():
	self.cards_picked.emit([])

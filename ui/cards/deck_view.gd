extends Control
class_name DeckView

const card_prefab = preload("res://ui/cards/card_view.tscn")

@onready var card_container = %CardContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func clean_up():
	for card in self.card_container.get_children():
		card.queue_free()


func init(cards: Array):
	self.clean_up()
	for c in cards:
		var cardView = card_prefab.instantiate()
		cardView.card = c
		self.card_container.add_child(cardView)

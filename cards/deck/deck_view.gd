extends CanvasLayer

const card_prefab = preload("res://cards/card_view/card_view.tscn")

@onready var card_container = %CardContainer
@onready var outside = %PopupOutside


# Called when the node enters the scene tree for the first time.
func _ready():
	outside.clicked.connect(Callable(self, "hide"))


func clean_up():
	for card in self.card_container.get_children():
		card.queue_free()


func init(cards: Array):
	self.clean_up()
	for c in cards:
		var cardView = card_prefab.instantiate()
		cardView.is_static = true
		cardView.card = c
		self.card_container.add_child(cardView)
		cardView.flip()
		cardView.flip_in_place()
		await Utils.wait(Constants.DECK_LONG_TIMER)

extends CanvasLayer

const card_prefab = preload("res://cards/card_view/card_view.tscn")
signal card_picked(card: Card)

@onready var card_container = %CardContainer
@onready var outside = %PopupOutside


# Called when the node enters the scene tree for the first time.
func _ready():
	outside.clicked.connect(Callable(self, "hide"))


func clean_up():
	for card in self.card_container.get_children():
		card.queue_free()

func pick_card(cv: CardView):
	self.card_picked.emit(cv.card)

func init(cards: Array):
	self.clean_up()
	for c in cards:
		var cardView = card_prefab.instantiate()
		cardView.is_static = true
		cardView.card = c
		cardView.picked.connect(Callable(self, "pick_card"))
		self.card_container.add_child(cardView)
		cardView.flip()
		cardView.flip_in_place()
		await Utils.wait(Constants.DECK_LONG_TIMER)

extends Control
signal event_over()

const card_view_prefab = preload("res://cards/card_view/card_view.tscn")
var picked : bool = false

@onready var cards_container = %CardsContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(3):
		var card = Cards.data.keys()[randi() % Cards.data.size()]
		var cv = card_view_prefab.instantiate()
		cv.card = Cards.get_instance(card)
		cv.is_static = true
		cv.picked.connect(Callable(self, "pick_card"))
		cards_container.add_child(cv)
		cv.flip()
		
		#await Utils.wait(Constants.DECK_LONG_TIMER)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pick_card(cv):
	if picked:
		return
	picked = true
	cv.flip_in_place()
	await Utils.wait(Constants.DECK_LONG_TIMER*10)
	Info.run.deck.push_back(cv.card)
	over()

func _on_skip_button_pressed():
	over()

func over():
	event_over.emit()

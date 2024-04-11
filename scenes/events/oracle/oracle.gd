extends Control
signal event_over

@onready var deck_view = %DeckView
var picked : bool = false


func _on_pick_card_button_pressed():
	deck_view.card_picked.connect(Callable(self, "card_picked"))
	deck_view.init(Info.run.deck)
	deck_view.show()


func card_picked(card):
	if picked:
		return
	picked = true
	deck_view.hide()
	Info.run.deck.erase(card)
	over()


func _on_skip_button_pressed():
	over()

func over():
	event_over.emit()

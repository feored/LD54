extends Control
signal event_over

@onready var deck_view = %DeckView


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


func card_picked(card_view):
	deck_view.hide()
	Info.run.deck.erase(card_view.card)
	over()

func _on_pick_card_button_pressed():
	deck_view.init(Info.run.deck)
	for cv in deck_view.card_views:
		cv.picked.connect(Callable(self, "card_picked"))
	deck_view.show()



func _on_option_1_btn_pressed():
	for card in Info.run.deck:
		var is_modified = false
		for effect in card.effects:
			if effect.type == "power" and effect.power == "reinforcements":
				effect.value = effect.value * 2
				is_modified = true
		if is_modified:
			card.cost += 1
	over()


func _on_option_2_btn_pressed():
	for card in Info.run.deck:
		var is_modified = false
		for effect in card.effects:
			if effect.type == "power" and effect.power in ["sink", "emerge"]:
				is_modified = true
				## add a tile to the shape
				var added_tile = false
				for i in range(99):
					for j in range(99):
						if not effect.value.has([i,j]):
							effect.value.append([i,j])
							added_tile = true
							break
					if added_tile:
						break
		if is_modified:
			card.cost += 1
	over()


func _on_option_3_btn_pressed():
	var to_erase = []
	var largeOfferings = 0
	for card in Info.run.deck:
		if card.name == "Offering":
			largeOfferings += 1
			to_erase.push_back(card)
		if card.name == "Sacrifice":
			to_erase.push_back(card)
	for card in to_erase:
		Info.run.deck.erase(card)
	for i in range(largeOfferings):
		Info.run.deck.push_back(Cards.get_instance("LargeOffering"))
	over()


func over():
	event_over.emit()

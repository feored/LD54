extends RefCounted
class_name Run


var deck : Array[Card] = []
var map : Map
var coords : Vector2i = Map.START

func _init():
	map = Map.new()
	for card_id in CardData.Cards.values():
		for i in range(2):
			var card  = CardData.get_instance(card_id)
			self.deck.push_back(card)
			self.deck.push_back(CardData.get_instance(CardData.Cards.Offering))

func get_open_nodes():
	if self.coords == Map.START:
		return map.get_entrances()
	else:
		return map.map[self.coords].next

func get_floor():
	return self.coords.x

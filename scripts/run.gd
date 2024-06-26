extends RefCounted
class_name Run

const STARTING_DECK = ["Offering", "Sacrifice", "Flood", "Creation", "CretanArchers", "CretanArchers"]

var deck : Array[Card] = []
var map : Map
var coords : Vector2i = Map.START

func _init():
	map = Map.new()
	for card_id in STARTING_DECK:
		var card  = Cards.get_instance(card_id)
		self.deck.push_back(card)

func get_open_nodes():
	if self.coords == Map.START:
		return map.get_entrances()
	else:
		return map.map[self.coords].next

func get_floor():
	return self.coords.x

func is_beaten():
	return self.map.boss.visited

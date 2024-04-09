extends RefCounted
class_name Card

var id: String
var name: String
var effects: Array
var description: String
var cost: int
var icon: Texture
var exhaust: bool = false


func _init(card_json: Dictionary):
	id = card_json["id"]
	name = card_json["name"]
	for e in card_json["effects"]:
		self.effects.push_back(Effect.new(e))
	description = card_json["description"]
	cost = card_json["cost"]
	icon = load(card_json["icon"]) if card_json.has("icon") else null
	exhaust = card_json.has("exhaust") and card_json["exhaust"]

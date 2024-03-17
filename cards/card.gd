extends RefCounted
class_name Card

var name: String
var effects: Array
var description: String
var cost: int
var requirements: Array
var icon: Texture


func _init(card_json: Dictionary):
	name = card_json["name"]
	effects = card_json["effects"]
	description = card_json["description"]
	cost = card_json["cost"]
	requirements = card_json["requirements"]
	icon = load(card_json["icon"])

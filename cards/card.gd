extends RefCounted
class_name Card


var name : String
var effects : Array
var description : String
var cost: int
var requirements: Array
var icon: Texture

const DEFAULT_CARD = {
	"name": "Offering",
	"effects": [
		{
			"event": "play",
			"type" : "resource",
			"resource": "faith",
			"value": "faith + 1"
		}
	],
	"description": "Make an offering to Neptune and gain 1 faith.",
	"cost": 0,
	"requirements": [],
	"icon": "res://assets/icons/trident.png"
}

func _init(card_json : Dictionary):
	name = card_json["name"]
	effects = card_json["effects"]
	description = card_json["description"]
	cost = card_json["cost"]
	requirements = card_json["requirements"]
	icon = load(card_json["icon"])

extends Node

const CARD_DATA_PATH = "res://cards/data.json"

var data: Dictionary


func _ready():
	var card_file = FileAccess.open(CARD_DATA_PATH, FileAccess.READ)
	self.data = JSON.parse_string(card_file.get_as_text())


func get_instance(id: String):
	return Card.new(self.data[id])

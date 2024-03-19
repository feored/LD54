extends RefCounted
class_name Player

var team: int = 0
var eliminated: bool = false
var resources: Dictionary = {}
var cards_in_use: Array = []
var is_bot: bool = false
var bot: Bot = null

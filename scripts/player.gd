extends RefCounted
class_name Player

var team: int = 0
var eliminated: bool = false
var resources: Dictionary = DEFAULT_RESOURCES.duplicate()
var cards_in_use: Array = []
var is_bot: bool = false
var bot: Bot = null

const DEFAULT_RESOURCES = {"faith": 0, "faith_per_turn": 5}

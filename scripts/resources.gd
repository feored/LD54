extends RefCounted
class_name Resources

var gold: int = 0
var faith: int = 0

var resource_changed = null

func init_callback(init_resource_changed):
	self.resource_changed = init_resource_changed
	self.resource_changed.call()

func _init(init_gold, init_faith,):
	gold = init_gold
	faith = init_faith

func set_gold(new_gold):
	gold = new_gold
	if resource_changed != null:
		resource_changed.call()

func add_gold(amount):
	gold += amount
	if resource_changed != null:
		resource_changed.call()

func set_faith(new_faith):
	faith = new_faith
	if resource_changed != null:
		resource_changed.call()

func add_faith(amount):
	faith += amount
	if resource_changed != null:
		resource_changed.call()

func clone():
	var new_resources = Resources.new(gold, faith)
	return new_resources

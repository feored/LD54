extends RefCounted
class_name Resources

var gold: int = 0
var favor: int = 0

var resource_changed = null

func init_callback(init_resource_changed):
	self.resource_changed = init_resource_changed
	self.resource_changed.call()

func _init(init_gold, init_favor,):
	gold = init_gold
	favor = init_favor

func set_gold(new_gold):
	gold = new_gold
	if resource_changed != null:
		resource_changed.call()

func add_gold(amount):
	gold += amount
	if resource_changed != null:
		resource_changed.call()

func set_favor(new_favor):
	favor = new_favor
	if resource_changed != null:
		resource_changed.call()

func add_favor(amount):
	favor += amount
	if resource_changed != null:
		resource_changed.call()

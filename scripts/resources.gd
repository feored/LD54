extends RefCounted
class_name Resources

var gold: int = 0
var favor: int = 0

var favor_changed = null
var gold_changed = null

func init_callbacks( init_gold_changed, init_favor_changed):
	gold_changed = init_gold_changed
	favor_changed = init_favor_changed
	gold_changed.call()
	favor_changed.call()

func _init(init_gold, init_favor,):
	gold = init_gold
	favor = init_favor

func set_gold(new_gold):
	gold = new_gold
	if gold_changed != null:
		gold_changed.call()

func add_gold(amount):
	gold += amount
	if gold_changed != null:
		gold_changed.call()

func set_favor(new_favor):
	favor = new_favor
	if favor_changed != null:
		favor_changed.call()

func add_favor(amount):
	favor += amount
	if favor_changed != null:
		favor_changed.call()

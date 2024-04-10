extends Control

const card_view_prefab = preload("res://cards/card_view/card_view.tscn")

@onready var cards_container = %CardsContainer
@onready var rewards = %Rewards
@onready var loss = %Loss

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Info.lost:
		self.rewards.show()
		self.loss.hide()
		for i in range(3):
			var card = Cards.data.keys()[randi() % Cards.data.size()]
			var cv = card_view_prefab.instantiate()
			cv.card = Cards.get_instance(card)
			cv.is_static = true
			cv.picked.connect(Callable(self, "pick_card"))
			cards_container.add_child(cv)
			cv.flip()
			cv.flip_in_place()
			await Utils.wait(Constants.DECK_LONG_TIMER)
	else:
		self.rewards.hide()
		self.loss.show()
	

func init(init_win : bool):
	self.win = init_win

func pick_card(cv):
	Info.run.deck.push_back(cv.card)
	next()

func next():
	await SceneTransition.change_scene(SceneTransition.SCENE_OVERWORLD)

func lose():
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_MENU)

func _on_continue_btn_pressed():
	next()

func _on_continue_loss_btn_pressed():
	lose()

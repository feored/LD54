extends Control


const CARD_SIZE = Vector2(125, 165)
const CARD_SPACING : float = 125
const CENTER = Vector2(Constants.VIEWPORT_SIZE.x / 2.0 - CARD_SIZE.x/2.0, 425.0)
const POSITION_CURVE = preload("res://cards/card_view/position_curve.tres")
const DRAW_POS = Vector2(-100, 440)
const DISCARD_POS = Vector2(1060, 440) 

const card_prefab = preload("res://cards/card_view/card_view.tscn")

@onready var draw_pile_label : Label = %DrawPileLabel
@onready var discard_pile_label : Label = %DiscardPileLabel
@onready var deck_view = %DeckView
@onready var draw_pile_deck : Control

var card_played : Callable

var draw_pile = []
var discard_pile = []
var play_pile = []
var exhausted = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for c in Info.run.deck:
		self.draw_pile.push_back(c)
	self.draw_pile.shuffle()

func draw_multiple(amount: int):
	for i in range(amount):
		await draw()
		Effects.trigger(Effect.Trigger.CardDrawn)

func discard_to_draw():
	for c in self.discard_pile:
		self.draw_pile.push_back(c)
	self.discard_pile.clear()
	self.draw_pile.shuffle()

func draw():
	if self.draw_pile.size() == 0:
		discard_to_draw()
		if self.draw_pile.size() == 0:
			return
	var cardView = card_prefab.instantiate()
	cardView.state = CardView.State.DrawnOrDiscarded
	cardView.card = self.draw_pile.pop_front()
	self.add_card(cardView)
	await Utils.wait(Constants.DECK_SHORT_TIMER)
	cardView.card_ready = true
	update_display()
	

func add_card(cv):
	cv.disconnect_picked()
	cv.picked.connect(func(cv): card_played.call(cv))
	add_child(cv)
	cv.position = DRAW_POS
	self.play_pile.append(cv)
	place_all()
	update_display()

func place_all():
	for i in range(self.play_pile.size()):
		var card_placement = place_card(self.play_pile[i])
		self.play_pile[i].base_position = card_placement[0]
		self.play_pile[i].move(card_placement[0])
		#self.play_pile[i].rotation_degrees = card_placement[1]

func discard(cardView):
	var card_id = self.play_pile.find(cardView)
	Utils.log("Discarding card: ", card_id)
	if card_id != -1:
		self.play_pile.remove_at(card_id)
		self.discard_pile.push_back(cardView.card)
		await cardView.discard(DISCARD_POS)
		Effects.trigger(Effect.Trigger.CardDiscarded)
	self.place_all()
	update_display()

func exhaust(cardView):
	var card_id = self.play_pile.find(cardView)
	if card_id != -1:
		self.play_pile.remove_at(card_id)
		self.exhausted.push_back(cardView.card)
		cardView.queue_free()
		self.place_all()
		Effects.trigger(Effect.Trigger.CardExhausted)
	await Utils.wait(Constants.DECK_LONG_TIMER)
	update_display()

func discard_random(amount: int):
	var drawn_copy = self.play_pile.duplicate()
	drawn_copy.shuffle()
	var to_del = min(drawn_copy.size(), amount)
	for i in range(to_del):
		await self.discard(drawn_copy[i])

func discard_all():
	while self.play_pile.size() > 0:
		await discard(self.play_pile[0])
	self.play_pile.clear()


func place_card(card):
	var id = self.play_pile.find(card)
	var total = self.play_pile.size()
	var middle = floor(total / 2.0)
	var num = id - middle
	var spacing = CARD_SPACING if play_pile.size() <= 3 else (CARD_SPACING - 12.5 * (play_pile.size() - 3))
	var x = CENTER.x + num * spacing
	var to_sample
	if total <= 1:
		to_sample = 00
	else:
		to_sample = id / (total - 1.0)
	var y = CENTER.y #- POSITION_CURVE.sample(to_sample)
	# print("x: ", x, "y: ", y, "to_sample: ", to_sample)
	return [Vector2(x, y), 0]#2 * num]
	

func update_faith(new_faith):
	for card in self.play_pile:
		card.set_buyable(card.card.cost <= new_faith)


func update_display():
	self.draw_pile_label.text = str(self.draw_pile.size())
	self.discard_pile_label.text = str(self.discard_pile.size())

func _on_discard_pile_button_pressed():
	self.deck_view.init(self.discard_pile)
	self.deck_view.show()

func _on_draw_pile_button_pressed():
	self.deck_view.init(self.draw_pile)
	self.deck_view.show()

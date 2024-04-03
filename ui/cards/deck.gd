extends Control


const CARD_SIZE = Vector2(125, 165)
const CARD_SPACING = 100
const CENTER = Vector2(Constants.VIEWPORT_SIZE.x / 2.0 - CARD_SIZE.x/2.0, 425.0)
const POSITION_CURVE = preload("res://ui/cards/position_curve.tres")

const DRAWN_MAX = 8

const card_prefab = preload("res://ui/cards/card_view.tscn")

@onready var draw_pile_label : Label = %DrawPileLabel
@onready var discard_pile_label : Label = %DiscardPileLabel
@onready var deck_view = %DeckView
@onready var deck_view_popup : Popup = %DeckViewPopup
@onready var draw_pile_deck : Control

var card_played : Callable

var draw_pile = []
var discard_pile = []
var play_pile = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for c in Info.run.deck:
		self.draw_pile.push_back(c)
	self.draw_pile.shuffle()

func draw(amount: int):
	var to_draw = min(amount, DRAWN_MAX - self.play_pile.size())
	var can_draw = min(to_draw, self.draw_pile.size())
	for i in range(can_draw):
		var cardView = card_prefab.instantiate()
		cardView.card = self.draw_pile.pop_front()
		self.add_card(cardView)
		await Utils.wait(0.1)
	if to_draw > can_draw:
		for c in self.discard_pile:
			self.draw_pile.push_back(c)
		self.discard_pile.clear()
		var can_still_draw = min(to_draw - can_draw, self.draw_pile.size())
		for i in range(can_still_draw):
			var cardView = card_prefab.instantiate()
			cardView.card = self.draw_pile.pop_front()
			self.add_card(cardView)
			await Utils.wait(0.1)

func add_card(card):
	card.disconnect_picked()
	card.picked.connect(func(card): card_played.call(card))
	self.play_pile.append(card)
	add_child(card)
	self.place_all()
	update_display()

func place_all():
	for i in range(self.play_pile.size()):
		var card_placement = place_card(self.play_pile[i])
		self.play_pile[i].base_position = card_placement[0]
		self.play_pile[i].set_position(card_placement[0])
		#self.play_pile[i].rotation_degrees = card_placement[1]

func discard(cardView):
	var card_id = self.play_pile.find(cardView)
	if card_id != -1:
		self.play_pile.remove_at(card_id)
		self.discard_pile.push_back(cardView.card)
		cardView.queue_free()
		self.place_all()
	await Utils.wait(0.1)
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
	var x = CENTER.x + num * CARD_SPACING
	var to_sample
	if total <= 1:
		to_sample = 00
	else:
		to_sample = id / (total - 1.0)
	var y = CENTER.y - POSITION_CURVE.sample(to_sample)
	# print("x: ", x, "y: ", y, "to_sample: ", to_sample)
	return [Vector2(x, y), 2 * num]
	

func update_faith(new_faith):
	for card in self.play_pile:
		card.set_buyable(card.card.cost <= new_faith)


func update_display():
	self.draw_pile_label.text = str(self.draw_pile.size())
	self.discard_pile_label.text = str(self.discard_pile.size())

func _on_discard_pile_button_pressed():
	self.deck_view.init(self.discard_pile)
	self.deck_view_popup.show()

func _on_draw_pile_button_pressed():
	self.deck_view.init(self.draw_pile)
	self.deck_view_popup.show()

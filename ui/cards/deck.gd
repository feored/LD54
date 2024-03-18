extends Control

const CARD_SIZE = Vector2(125, 165)
const CARD_SPACING = 100
const CENTER = Vector2(Constants.VIEWPORT_SIZE.x / 2.0 - CARD_SIZE.x/2.0, 425.0)
const POSITION_CURVE = preload("res://ui/cards/position_curve.tres")

const BASE_Z_INDEX = 0
const HOVER_Z_INDEX = 1

const DRAWN_MAX = 8

const card_prefab = preload("res://ui/cards/card_view.tscn")
var card_played : Callable

var cards = []
var drawn = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for card_id in CardData.Cards.values():
		for i in range(2):
			var card  = CardData.get_instance(card_id)
			self.cards.push_back(card)
	self.cards.shuffle()

func draw(amount: int):
	var to_draw = min(min(amount, cards.size()), DRAWN_MAX - drawn.size())
	for i in range(to_draw):
		var cardView = card_prefab.instantiate()
		cardView.card = cards.pop_front()
		self.add_card(cardView)

func add_card(card):
	card.mouse_entered.connect(func(): try_hover(card))
	card.mouse_exited.connect(func(): try_unhover(card))
	card.disconnect_picked()
	card.picked.connect(func(card): card_played.call(card))
	drawn.append(card)
	add_child(card)
	self.place_all()

func place_all():
	for i in range(drawn.size()):
		var card_placement = place_card(drawn[i])
		self.drawn[i].set_position(card_placement[0])
		#self.drawn[i].rotation_degrees = card_placement[1]

func discard(cardView):
	var card_id = drawn.find(cardView)
	if card_id != -1:
		self.drawn.remove_at(card_id)
		self.cards.push_back(cardView.card)
		cardView.queue_free()
		self.place_all()

func discard_random(amount: int):
	var drawn_copy = self.drawn.duplicate()
	drawn_copy.shuffle()
	var to_del = min(drawn_copy.size(), amount)
	for i in range(to_del):
		self.discard(drawn_copy[i])

func discard_all():
	while drawn.size() > 0:
		discard(drawn[0])
	drawn.clear()


func place_card(card):
	var id = drawn.find(card)
	var total = drawn.size()
	var middle = floor(total / 2.0)
	var num = id - middle
	var x = CENTER.x + num * CARD_SPACING
	var to_sample
	if total <= 1:
		to_sample = 00
	else:
		to_sample = id / (total - 1.0)
	var y = CENTER.y# - POSITION_CURVE.sample(to_sample)
	# print("x: ", x, "y: ", y, "to_sample: ", to_sample)
	return [Vector2(x, y), 0]#2 * num]
	


func try_hover(card):
	if card.state == CardView.State.Base:
		hover(card)
		#print("Start hovering ", card_id, " at ", card.position, " with mouse position : ", get_global_mouse_position())
		

func hover(card):
	for i in range(drawn.size()):
		if drawn[i] != card:
			unhover(drawn[i])
	var new_pos = card.position
	new_pos.y -= 100
	card.animate(new_pos, 0, HOVER_Z_INDEX)
	card.state = CardView.State.Hovering


func try_unhover(card):
	if card.state == CardView.State.Hovering:
		# check that the mouse is not just caught in a child
		if not card.mouse_inside():
			unhover(card)
			# print("Start unhovering ", card_id, " at ", card.position, " with mouse position : ", get_global_mouse_position())
			

func unhover(card):
	card.z_index = BASE_Z_INDEX
	var card_placement = self.place_card(card)
	card.animate(card_placement[0], card_placement[1], BASE_Z_INDEX)
	card.state = CardView.State.Base

func update_faith(new_faith):
	for card in drawn:
		card.set_buyable(card.card.cost <= new_faith)

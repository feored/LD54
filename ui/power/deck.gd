extends Control

const CARD_SIZE = Vector2(125, 165)
const CARD_SPACING = 100
const CENTER = Vector2(Constants.VIEWPORT_SIZE.x / 2.0 - CARD_SIZE.x/2.0, 425.0)
const POSITION_CURVE = preload("res://ui/power/position_curve.tres")

const BASE_Z_INDEX = 0
const HOVER_Z_INDEX = 1

var cards = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.

func add_card(card):
	card.mouse_entered.connect(func(): try_hover(cards.find(card)))
	card.mouse_exited.connect(func(): try_unhover(cards.find(card)))
	cards.append(card)
	add_child(card)
	self.place_all()

func place_all():
	for i in range(cards.size()):
		var card_placement = place_card(i)
		self.cards[i].set_position(card_placement[0])
		self.cards[i].rotation_degrees = card_placement[1]

func remove_card(card):
	var card_id = cards.find(card)
	if card_id != -1:
		self.cards.remove_at(card_id)
		self.remove_child(card)
		card.queue_free()
		self.place_all()


func place_card(id):
	var total = cards.size()
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
	


func try_hover(card_id):
	if self.cards[card_id].state == PowerCard.State.Base:
		hover(card_id)
		#print("Start hovering ", card_id, " at ", card.position, " with mouse position : ", get_global_mouse_position())
		

func hover(card_id):
	for i in range(cards.size()):
		if i != card_id:
			unhover(i)
	var new_pos = self.cards[card_id].position
	new_pos.y -= 100
	self.cards[card_id].animate(new_pos, 0, HOVER_Z_INDEX)
	self.cards[card_id].state = PowerCard.State.Hovering


func try_unhover(card_id):
	var card = self.cards[card_id]
	if card.state == PowerCard.State.Hovering:
		# check that the mouse is not just caught in a child
		if not card.mouse_inside():
			unhover(card_id)
			# print("Start unhovering ", card_id, " at ", card.position, " with mouse position : ", get_global_mouse_position())
			

func unhover(card_id):
	self.cards[card_id].z_index = BASE_Z_INDEX
	var card_placement = self.place_card(card_id)
	self.cards[card_id].animate(card_placement[0], card_placement[1], BASE_Z_INDEX)
	self.cards[card_id].state = PowerCard.State.Base

func update_faith(new_faith):
	for card in cards:
		card.set_buyable(card.power.cost <= new_faith)

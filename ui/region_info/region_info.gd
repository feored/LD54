extends PanelContainer

enum State { Buttons, Buildings, Info}

signal tile_unselected(coords)

const ANIM_APPEAR = "appear"
const ANIM_DISAPPEAR = "disappear"
const building_popup_prefab = preload("res://ui/region_info/building_popup.tscn")

@onready var buttons_container = %ButtonContainer
@onready var info_container = %InfoContainer
@onready var buildings_container = %BuildingsContainer

@onready var owner_label = %OwnerLabel
@onready var size_label = %SizeLabel
@onready var favor_label = %FavorLabel
@onready var gold_label = %GoldLabel
@onready var resources_container = %ResourcesContainer
@onready var animation_player = $AnimationPlayer

@export var busy = false
@export var shown = false

var active = true
var child_popup = null

var tile_coords = Constants.NULL_COORDS

var built = Constants.NULL_BUILDING
var available_buildings = []

var region_owner : int = 0
var region_size : int = 0
var favor : int = 0
var gold : int = 0

const MARGIN = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()

func show_state(state: int):
	match state:
		State.Buttons:
			buttons_container.show()
			buildings_container.hide()
			info_container.hide()
		State.Buildings:
			buildings_update()
			buttons_container.hide()
			buildings_container.show()
			info_container.hide()
		State.Info:
			info_update()
			buttons_container.hide()
			buildings_container.hide()
			info_container.show()
	self.reset_size()

func info_update():
	owner_label.text = Constants.TEAM_NAMES[region_owner]
	size_label.text = str(region_size)
	favor_label.text = str(favor)
	gold_label.text = str(gold)
	if region_owner == 0:
		resources_container.hide()
	else:
		resources_container.show()

func make_building_popup(building: int, is_built: bool):
	var popup_closed = func():
		print("POPUP CLOSED")
		self.child_popup = null
		self.active = true
	if self.child_popup != null:
		self.child_popup.queue_free()
	self.active = false
	self.child_popup = building_popup_prefab.instantiate()
	self.child_popup.init(building, is_built, popup_closed)
	self.child_popup.position = self.position + Vector2(MARGIN, MARGIN) + Vector2(8, 8)
	self.get_parent().add_child(self.child_popup)
	print("MADE POPUP")

func make_building(building: int, is_built: bool):
	print("MAKING BUILDING", building)
	var new_building = TextureRect.new()
	new_building.texture = Constants.BUILDINGS[building].texture
	new_building.mouse_entered.connect(func(): make_building_popup(building, is_built))
	return new_building

func buildings_update():
	for child in self.buildings_container.get_children():
		child.queue_free()
	if built != Constants.NULL_BUILDING:
		self.buildings_container.add_child(make_building(self.built, true))
	else:
		for building in self.available_buildings:
			self.buildings_container.add_child(make_building(building, false))

func init(coords, init_available_building, init_built, init_region_owner, init_region_size, init_favor, init_gold):
	shown = true
	tile_coords = coords
	available_buildings = init_available_building
	built = init_built
	region_owner = init_region_owner
	region_size = init_region_size
	favor = init_favor
	gold = init_gold
	self.show_state(State.Buttons)
	self.appear()

func appear():
	if not busy:
		busy = true
		shown = true
		animation_player.play(ANIM_APPEAR)
		
func disappear_instant():
	self.hide()
	self.scale = Vector2.ZERO
	shown = false
	busy = false
	if child_popup != null:
		child_popup.queue_free()
	tile_unselected.emit(self.tile_coords)
	
func disappear():
	if not busy:
		busy = true
		animation_player.play(ANIM_DISAPPEAR)
		tile_unselected.emit(self.tile_coords)
		if child_popup != null:
			child_popup.queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shown and active and not busy:
		var mouse_pos = get_local_mouse_position()
		if (mouse_pos.x < -MARGIN * 3) or (mouse_pos.x > self.size.x + MARGIN) or (mouse_pos.y < -MARGIN * 3) or (mouse_pos.y > self.size.y + MARGIN):
			self.disappear()



func _on_info_button_pressed():
	self.show_state(State.Info)

func _on_building_button_pressed():
	self.show_state(State.Buildings)

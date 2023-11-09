extends PanelContainer

enum State { Buttons, Buildings, Info}

signal tile_unselected(coords)

const ANIM_APPEAR = "appear"
const ANIM_DISAPPEAR = "disappear"
const building_popup_prefab = preload("res://ui/region_info/building_popup.tscn")


@onready var buildings_container = %BuildingsContainer
@onready var animation_player = $AnimationPlayer

@export var busy = false
@export var shown = false

var active = true
var child_popup = null
var current_gold = 0
var buy_func : Callable

var tile_coords = Constants.NULL_COORDS

var built = Constants.Building.None
var available_buildings = []


const MARGIN = 5
const RADIUS = 50



# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	self.buildings_update()
	self.reset_size()

func make_building_popup(building: int, is_built: bool):
	self.active = false
	self.child_popup = building_popup_prefab.instantiate()
	self.child_popup.init(building, is_built, Callable(self, "on_popup_closed"))
	self.child_popup.position = get_global_mouse_position() + Vector2(MARGIN, MARGIN)
	self.get_parent().add_child(self.child_popup)

func _on_popup_closed():
	if self.child_popup != null:
		self.child_popup.queue_free()
	self.child_popup = null
	self.active = true

func make_building(building: int, is_built: bool):
	var new_building = Button.new()
	new_building.icon = Constants.BUILDINGS[building].texture
	new_building.mouse_entered.connect(func(): make_building_popup(building, is_built))
	new_building.mouse_exited.connect(func(): _on_popup_closed())
	new_building.pressed.connect(func(): buy_func.call(self.tile_coords, building))
	new_building.disabled = is_built or Constants.BUILDINGS[building].cost > current_gold
	return new_building

func buildings_update():
	for child in self.buildings_container.get_children():
		child.queue_free()
	if built != Constants.Building.None:
		self.buildings_container.add_child(make_building(self.built, true))
	else:
		var angle = TAU / self.available_buildings.size()
		for i in range(self.available_buildings.size()):
			var building = self.available_buildings[i]
			var new_building = make_building(building, false)
			new_building.text = str(i)
			var center = func(node):
				node.position -= node.size/2
				print(node.size)
			new_building.ready.connect(func(): center.call(new_building))
			new_building.position = Vector2(RADIUS * sin(angle * i), RADIUS * cos(angle * i))
			print(new_building.position)
			self.buildings_container.add_child(new_building)
	

func init(coords, init_available_building, init_built, init_gold, init_buy_func):
	shown = true
	tile_coords = coords
	available_buildings = init_available_building
	built = init_built
	current_gold = init_gold
	buy_func = init_buy_func
	self.buildings_update()
	self.reset_size()
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
	_on_disappear()
	tile_unselected.emit(self.tile_coords)

func _on_disappear():
	for child in self.buildings_container.get_children():
		child.queue_free()
	
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
		if (mouse_pos.x < -RADIUS - MARGIN) or (mouse_pos.x > RADIUS + MARGIN) or (mouse_pos.y < -RADIUS -MARGIN) or (mouse_pos.y > RADIUS + MARGIN):
			self.disappear()

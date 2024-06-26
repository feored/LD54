extends Node
signal event_started(event)

const X_OFFSET = 100
const Y_OFFSET = 100
const BTN_SIZE = Vector2(32, 32)
const BTN_SIZE_HALF = BTN_SIZE / 2

const btnPrefab = preload("res://scenes/overworld/map_view/map_location.tscn")

@onready var lines_panel = %LinesPanel
@onready var floor_label = %FloorLabel
@onready var btns = {}

var tooltip = null


func coords_to_btnpos(coords):
	return Vector2(X_OFFSET + coords.y * 100,  Y_OFFSET + (Map.MAP_HEIGHT - coords.x) * 100) + Vector2(Utils.rng.randf_range(-20, 20), Utils.rng.randf_range(-10, 10))


func clear():
	for btn in btns.values():
		btn.queue_free()
	btns.clear()
	lines_panel.coords = []
	lines_panel.visited = []

func scroll_to_floor():
	var tween_pos = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	var new_y =  coords_to_btnpos(Vector2(Info.run.get_floor(), 0)).y - Constants.VIEWPORT_SIZE.y/2
	print( coords_to_btnpos(Vector2(Info.run.get_floor(), 0)))
	tween_pos.tween_property(self, "scroll_vertical", new_y, 0.25)
	
func show_tooltip(new_tooltip, pos):
	if self.tooltip != null:
		self.tooltip.queue_free()
	self.tooltip = new_tooltip
	self.tooltip.position = pos
	self.lines_panel.add_child(tooltip)

func hide_tooltip():
	if self.tooltip != null:
		self.tooltip.queue_free()
	self.tooltip = null
	
func draw_map():
	floor_label.set_text("Floor " + str(Info.run.get_floor() + 1))
	var open = Info.run.get_open_nodes()
	for k in Info.run.map.map.keys():
		var btn = btnPrefab.instantiate()
		# btn.set_text(str(k))
		btn.position = coords_to_btnpos(k)
		btn.show_tooltip.connect(Callable(self, "show_tooltip"))
		btn.hide_tooltip.connect(Callable(self, "hide_tooltip"))
		btn.init(Info.run.map.map[k])
		lines_panel.add_child(btn)
		btns[k] = btn
		if k not in open:
			btn.disabled = true
		if Info.run.map.map[k].visited:
			lines_panel.visited.push_back(btns[k].position + BTN_SIZE_HALF)
		btn.pressed.connect(func (): choose_location(k))
	for k in Info.run.map.map.keys():
		for end in Info.run.map.map[k].next:
			lines_panel.coords.push_back([btns[k].position + BTN_SIZE_HALF, btns[end].position + BTN_SIZE_HALF])

func _ready():
	draw_map()
	call_deferred("scroll_to_floor")


func choose_location(k):
	Info.run.coords = k
	Info.run.map.map[k].visited = true
	if Info.run.map.map[k].location == Map.Location.Map:
		Utils.log("Mods for selected map: ")
		for mod in Info.run.map.map[k].mods:
			Utils.log(MapMods.mods[mod].name)
		Info.set_map(Info.run.map.map[k].path)
		Info.current_mods = Info.run.map.map[k].mods
		await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_GAME)
	else:
		self.event_started.emit(Info.run.map.map[k].event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

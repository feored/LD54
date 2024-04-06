extends Node
signal event_started(event)

const X_OFFSET = 100
const btnPrefab = preload("res://scenes/overworld/button.tscn")

@onready var lines_panel = %LinesPanel
@onready var floor_label = %FloorLabel
@onready var btns = {}


func coords_to_btnpos(coords):
	return Vector2(X_OFFSET + coords.y * 100,  (Map.MAP_HEIGHT - coords.x) * 100) + Vector2(Utils.rng.randf_range(-20, 20), Utils.rng.randf_range(-10, 10))


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
	
	
	
func draw_map():
	floor_label.set_text("Floor " + str(Info.run.get_floor() + 1))
	var open = Info.run.get_open_nodes()
	for k in Info.run.map.map.keys():
		var btn = btnPrefab.instantiate()
		# btn.set_text(str(k))
		btn.position = coords_to_btnpos(k)
		lines_panel.add_child(btn)
		btns[k] = btn
		if k not in open:
			btn.disabled = true
		if Info.run.map.map[k].visited:
			lines_panel.visited.push_back(btns[k].position + Vector2(20, 16))
		if Info.run.map.map[k].location == Map.Location.Event:
			btn.icon = load("res://assets/icons/prayer.png")
		btn.pressed.connect(func (): choose_location(k))
	for k in Info.run.map.map.keys():
		for end in Info.run.map.map[k].next:
			lines_panel.coords.push_back([btns[k].position + Vector2(20, 16), btns[end].position + Vector2(20, 16)])

	## draw boss
	# var bossBtn = btnPrefab.instantiate()
	# bossBtn.position = coords_to_btnpos(Info.run.map.boss.info.coords)
	# lines_panel.add_child(bossBtn)
	# btns[Info.run.map.boss.info.coords] = bossBtn
	# bossBtn.pressed.connect(func (): choose_location(Info.run.map.boss))
	# lines_panel.coords.push_back([boss.position + Vector2(20, 16), btns[Info.run.map.boss].position + Vector2(20, 16)])
	# lines_panel.queue_redraw()


func _ready():
	draw_map()
	call_deferred("scroll_to_floor")


func choose_location(k):
	Info.run.coords = k
	Info.run.map.map[k].visited = true
	if Info.run.map.map[k].location == Map.Location.Map:
		print("Picking random map")
		Info.set_map(Info.run.map.map[k].info.path)
		await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_GAME)
	else:
		self.event_started.emit(Info.run.map.map[k].info.event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends PanelContainer

const mod_view_prefab = preload("res://scenes/overworld/mod_view/mod_view.tscn")

@onready var mod_container = %ModContainer

var mod_list
# Called when the node enters the scene tree for the first time.
func _ready():
	update_view()

func cleanup():
	for child in mod_container.get_children():
		child.queue_free()

func init(init_mod_list):
	self.mod_list = init_mod_list

func update_view():
	cleanup()
	for mod in mod_list:
		add_mod(mod)

func add_mod(mod):
	var mod_view = mod_view_prefab.instantiate()
	mod_view.init(mod)
	mod_container.add_child(mod_view)

extends PanelContainer

@onready var mod_name = %ModName
@onready var mod_level = %ModLevel
@onready var mod_description = %ModDescription

var mod = null
# Called when the node enters the scene tree for the first time.
func _ready():
	update_view()

func init(new_mod):
	self.mod = MapMods.mods[new_mod]

func update_view():
	if mod == null:
		return
	mod_name.text = mod.name
	mod_level.text = "[" + str(mod.level) + "]"
	mod_description.text = mod.description

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


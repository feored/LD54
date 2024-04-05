extends Container

@onready var titleLabel = $"%Title"
@onready var descriptionLabel = $"%Description"

var title = ""
var description = ""
var path = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	self.titleLabel.text = self.title
	self.descriptionLabel.text = self.description


func init(scenario):
	self.title = scenario.title
	self.description = scenario.description
	self.path = scenario.path


func _on_button_pressed():
	Info.set_map(self.path)
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_GAME)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

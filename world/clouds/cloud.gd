extends Sprite2D

@onready var shadow = $Shadow
var speed = 0
var parent = null
var cloud_texture = null


# Called when the node enters the scene tree for the first time.
func _ready():
	self.speed = Utils.rng.randi() % 20 + 1
	self.set_cloud_texture()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x += delta * speed * 4
	if self.position.x > Constants.WORLD_CAMERA_BOUNDS.x * Constants.TILE_SIZE:
		parent.remove_cloud(self)


func set_cloud_texture():
	self.texture = self.cloud_texture
	self.shadow.texture = self.cloud_texture
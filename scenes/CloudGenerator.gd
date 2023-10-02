extends Node2D
var cloudPrefab = preload("res://world/cloud.tscn")

const cloud_textures = [
	preload("res://assets/clouds/cloud_1.png"),
	preload("res://assets/clouds/cloud_2.png"),
	preload("res://assets/clouds/cloud_3.png"),
	preload("res://assets/clouds/cloud_3.png"),
	preload("res://assets/clouds/cloud_3.png"),
	preload("res://assets/clouds/cloud_3.png"),
	preload("res://assets/clouds/cloud_4.png")
]

var cloud_chance = 0.1
var elapsed = 0
var every = 0.1

var clouds = []
var max_clouds = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(max_clouds):
		generate_cloud(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed += delta
	if elapsed > every:
		elapsed = 0
		if randf() < cloud_chance and clouds.size() < max_clouds:
			generate_cloud(false)


func generate_cloud(init):
	var x = -Constants.WORLD_CAMERA_BOUNDS.x * 24
	if init:
		x = (
			Utils.rng.randi_range(-Constants.WORLD_CAMERA_BOUNDS.x, Constants.WORLD_CAMERA_BOUNDS.x)
			* 24
		)

	var cloud = cloudPrefab.instantiate()
	cloud.position = Vector2(
		x,
		(
			Utils.rng.randi_range(-Constants.WORLD_CAMERA_BOUNDS.y, Constants.WORLD_CAMERA_BOUNDS.y)
			* 24
		)
	)
	cloud.cloud_texture = cloud_textures[Utils.rng.randi_range(0, cloud_textures.size() - 1)]
	clouds.append(cloud)
	cloud.parent = self
	self.add_child(cloud)


func remove_cloud(cloud):
	clouds.erase(cloud)
	cloud.queue_free()

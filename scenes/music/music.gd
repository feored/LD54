extends AudioStreamPlayer

## Tracks
enum Track {
	Menu,
	World,
}
const BGM_TRACKS = {
	Track.Menu: preload("res://assets/music/pirate_4.ogg"),
	Track.World: preload("res://assets/music/pirate_7.ogg"),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func play_track(track: Track):
	self.stream = BGM_TRACKS[track]
	self.play()

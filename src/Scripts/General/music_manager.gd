extends Node

@onready var player: AudioStreamPlayer = $player

# Pass the path of your audio file as a string
func play_music(stream_path: String, volume_db: float = 0.0) -> void:
	# Check if the same music is already playing to avoid restarting it
	if player.stream and player.stream.resource_path == stream_path and player.playing:
		return
		
	var new_stream = load(stream_path)
	if new_stream:
		player.stream = new_stream
		player.volume_db = volume_db
		player.play()
	else:
		print("Failed to load music: ", stream_path)

func stop_music() -> void:
	player.stop()

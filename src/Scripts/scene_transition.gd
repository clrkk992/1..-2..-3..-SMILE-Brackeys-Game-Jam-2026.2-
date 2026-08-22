extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func load_scene(target_scene: String) -> void:
	animation_player.play("blink")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target_scene)
	animation_player.play_backwards("blink")
	
func reload_scene() -> void:
	animation_player.play("blink")
	await animation_player.animation_finished
	get_tree().reload_current_scene()
	animation_player.play_backwards("blink")

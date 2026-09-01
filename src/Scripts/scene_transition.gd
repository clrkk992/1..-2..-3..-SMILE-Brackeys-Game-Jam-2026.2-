extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func load_scene(target_scene: String) -> void:
	animation_player.play("black_flash")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target_scene)
	animation_player.play_backwards("blink")
	
func reload_scene() -> void:
	animation_player.play("blink")
	await animation_player.animation_finished
	get_tree().reload_current_scene()
	animation_player.play_backwards("blink")
	
func game_over() -> void:
	MusicManager.play_music("uid://dg8ptcwts4erk", -5.0) #wind
	animation_player.play("blink")
	await animation_player.animation_finished
	animation_player.play("game_over")
	
func the_end_yeyy() -> void:
	animation_player.play("the_end")

func _on_try_again_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://p25m6aa76m6")
	animation_player.play_backwards("blink")

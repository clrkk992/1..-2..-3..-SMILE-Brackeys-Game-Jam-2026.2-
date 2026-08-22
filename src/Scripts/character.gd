extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var animation_finished: bool = false

func walk_in() -> void:
	animation_finished = false
	animation_player.play("walk_in")
	await animation_player.animation_finished
	animation_player.play("idle")
	animation_finished = true
	
func walk_out() -> void:
	animation_finished = false
	animation_player.play("walk_out")
	await animation_player.animation_finished
	queue_free()
	animation_finished = true

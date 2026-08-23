extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite: Sprite3D = %Sprite3D

var animation_finished: bool = false
var texture: String = " "

func _ready() -> void:
	var randomizer = randi_range(1,4)
	match randomizer:
		1:
			texture = "uid://vyam02dvt42h" #ActorA_1
		2:
			texture = "uid://ci4kj1fxqu1qt" #ActorA_2
		3:
			texture = "uid://dgf4kj7rvr0ls" #ActorA_3
		4:
			texture = "uid://bciep55utw26t" #ActorA_4
			
	sprite.texture = load(texture)

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

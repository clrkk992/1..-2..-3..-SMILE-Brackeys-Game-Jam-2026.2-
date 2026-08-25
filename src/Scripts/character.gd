extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite: Sprite3D = %Sprite3D

@export var texture_array: Array[String] = []

var animation_finished: bool = false

func _ready() -> void:
	var randomizer = randi_range(0,18)
	sprite.texture = load(texture_array[randomizer])

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

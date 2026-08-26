extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite: Sprite3D = %Sprite3D
@onready var bar_animation_player: AnimationPlayer = %BarAnimationPlayer

enum EMOTION {
	GREAT,
	MEH,
	ANGRY
}

@export var texture_array: Array[String] = []
@export var current_emotion := EMOTION.GREAT

var animation_finished: bool = false
var walk_in_interrupted: bool = false

func _ready() -> void:
	var randomizer = randi_range(0,18)
	sprite.texture = load(texture_array[randomizer])

func walk_in() -> void:
	animation_finished = false
	
	animation_player.play("walk_in")
	await animation_player.animation_finished
	
	animation_player.play("idle")
	animation_finished = true
	
	bar_animation_player.play("progress_bar")
	await bar_animation_player.animation_finished
	
	#don't spawn new char if there is already a character spawned
	if walk_in_interrupted:
		return
		
	#spawn new character after timed out
	EventBus.character_finished.emit()
	
func walk_out() -> void:
	walk_in_interrupted = true #makes sure that the walk_in won't continue
	animation_finished = false
	
	bar_animation_player.play("emotion_show")
	await bar_animation_player.animation_finished
		
	animation_player.play("walk_out")
	await animation_player.animation_finished
	
	queue_free()
	animation_finished = true

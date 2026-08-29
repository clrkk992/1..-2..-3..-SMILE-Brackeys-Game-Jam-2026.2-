extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $Camera
@onready var camera_effect: ColorRect = %CameraEffect
@onready var light_button: Area3D = %LightButton
@onready var color_button: Area3D = %ColorButton
@onready var whoosh_sfx: AudioStreamPlayer3D = $WhooshSFX

@export var char_list: Array[Sprite3D] = []
var char_list_index := 0
var time := EventBus.time

enum STATE {
	CAMERA,
	CHECKLIST,
	LAPTOP
}

var current_state = STATE.CAMERA
var target_rotation := 0.0

func _ready() -> void:
	animation_player.play("camera")
	await animation_player.animation_finished
	camera_effect.visible = true
		
func _input(event):
	if current_state == STATE.CAMERA:
		if event.is_action_pressed("move_left"):
			animation_player.play_backwards("camera")
			await animation_player.animation_finished
			
			target_rotation += 90.0
			whoosh_sfx.play()
			tween_rotation()
			
			current_state = STATE.LAPTOP
			
		if event.is_action_pressed("move_right"):
			animation_player.play_backwards("camera")
			await animation_player.animation_finished
			
			target_rotation -= 90.0
			whoosh_sfx.play()
			tween_rotation()
			
			animation_player.play("clipboard")
			
			current_state = STATE.CHECKLIST
			
	elif current_state == STATE.CHECKLIST:
		if event.is_action_pressed("move_left"):
			animation_player.play_backwards("clipboard")
			await animation_player.animation_finished
			
			target_rotation += 90.0
			whoosh_sfx.play()
			tween_rotation()
			
			animation_player.play("camera")
			
			current_state = STATE.CAMERA
			
	elif current_state == STATE.LAPTOP:
		if event.is_action_pressed("move_right"):
			target_rotation -= 90.0
			whoosh_sfx.play()
			tween_rotation()
			
			animation_player.play("camera")
			
			current_state = STATE.CAMERA
			
func _physics_process(_delta: float) -> void:
	if char_list_index <= 7:
		char_list_index += 1
		
	if time == 10 or time == 12 or time == 2 or time == 4 or time == 6:
		char_list[char_list_index].visible = true
			
func tween_rotation() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "rotation_degrees:y", target_rotation, 0.3)

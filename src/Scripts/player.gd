extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $Camera
@onready var camera_effect: ColorRect = %CameraEffect

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
			tween_rotation()
			
			animation_player.play("laptop")
			
			current_state = STATE.LAPTOP
			
		if event.is_action_pressed("move_right"):
			animation_player.play_backwards("camera")
			await animation_player.animation_finished
			
			target_rotation -= 90.0
			tween_rotation()
			
			animation_player.play("clipboard")
			
			current_state = STATE.CHECKLIST
			
	if current_state == STATE.CHECKLIST:
		if event.is_action_pressed("move_left"):
			animation_player.play_backwards("clipboard")
			await animation_player.animation_finished
			
			target_rotation += 90.0
			tween_rotation()
			
			animation_player.play("camera")
			
			current_state = STATE.CAMERA
			
	if current_state == STATE.LAPTOP:
		if event.is_action_pressed("move_right"):
			animation_player.play_backwards("laptop")
			await animation_player.animation_finished
			
			target_rotation -= 90.0
			tween_rotation()
			
			animation_player.play("camera")
			
			current_state = STATE.CAMERA
			
func tween_rotation() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "rotation_degrees:y", target_rotation, 0.3)

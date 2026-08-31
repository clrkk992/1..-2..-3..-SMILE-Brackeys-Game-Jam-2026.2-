extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $Camera
@onready var camera_effect: ColorRect = %CameraEffect
@onready var light_button: Area3D = %LightButton
@onready var color_button: Area3D = %ColorButton
@onready var whoosh_sfx: AudioStreamPlayer3D = $WhooshSFX
@onready var time_label: Label3D = %Label3D
@onready var health_overlay: ColorRect = %HealthOverlay
@onready var health_text: Label3D = $ClipBoard/Health
@onready var health_animation_player: AnimationPlayer = $UI/Control/HealthAnimationPlayer

enum TYPE {
	PLAYER,
	VOID
}

@export var char_list: Array[Sprite3D] = []
@export var type = TYPE.PLAYER

enum STATE {
	CAMERA,
	CHECKLIST,
	LAPTOP
}

var current_state = STATE.CAMERA
var target_rotation := 0.0

var turning := true

func _ready() -> void:
	EventBus.take_health.connect(_take_health)
	EventBus.tutorial_started.connect(_tutorial_started)
	time_label.text = str(EventBus.time) + " " + str(EventBus.meridiem)
	
	var dialogue_resource = preload("res://src/Dialogues/main.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "dialogue_" + str(EventBus.dialogue_num))
	EventBus.dialogue_num += 1
	
	if EventBus.remove_no_one and type == TYPE.VOID:
		%Wife.visible = false
	elif !EventBus.remove_no_one and type == TYPE.VOID:
		%Wife.visible = true
	
	if type == TYPE.PLAYER:
		if EventBus.time == 8 or EventBus.time == 10 or EventBus.time == 12 or EventBus.time == 2 or EventBus.time == 4 or EventBus.time == 5:
			for i in range(EventBus.char_list_index + 1):
				char_list[i].randomize_char_clipboard.emit()
			if EventBus.char_list_index <= 5:
				EventBus.char_list_index += 1
	
func _tutorial_started() -> void:
	Mouse.cursor.visible = false
	animation_player.play("camera")
	camera_effect.visible = true
	await get_tree().create_timer(0.5).timeout
	turning = false
		
func _input(event):
	if !turning:
		if current_state == STATE.CAMERA:
			Mouse.cursor.visible = false
			if event.is_action_pressed("move_left"):
				turning = true
				animation_player.play_backwards("camera")
				await animation_player.animation_finished
				
				target_rotation = 90.0
				whoosh_sfx.play()
				tween_rotation()
				
				current_state = STATE.LAPTOP
				await get_tree().create_timer(0.5).timeout
				turning = false
			
			elif event.is_action_pressed("move_right"):
				turning = true
				animation_player.play_backwards("camera")
				await animation_player.animation_finished
				
				target_rotation = -90.0
				whoosh_sfx.play()
				tween_rotation()
				
				animation_player.play("clipboard")
				
				current_state = STATE.CHECKLIST
				await get_tree().create_timer(0.5).timeout
				turning = false
				
		elif current_state == STATE.CHECKLIST:
			if event.is_action_pressed("move_left"):
				turning = true
				animation_player.play_backwards("clipboard")
				await animation_player.animation_finished
				
				target_rotation = 0.0
				whoosh_sfx.play()
				tween_rotation()
				
				animation_player.play("camera")
				
				current_state = STATE.CAMERA
				await get_tree().create_timer(0.5).timeout
				turning = false
		
			elif event.is_action_pressed("move_right"):
				turning = true
				animation_player.play_backwards("clipboard")
				await animation_player.animation_finished
				
				target_rotation = -270.0
				whoosh_sfx.play()
				tween_rotation()
					
				current_state = STATE.LAPTOP
				await get_tree().create_timer(0.5).timeout
				turning = false
				
		elif current_state == STATE.LAPTOP:
			if event.is_action_pressed("move_right"):
				turning = true
				
				target_rotation = 0.0
				whoosh_sfx.play()
				tween_rotation()
				
				animation_player.play("camera")
				
				current_state = STATE.CAMERA
				await get_tree().create_timer(0.5).timeout
				turning = false
				
			elif event.is_action_pressed("move_left"):
				turning = true
				
				target_rotation = -90.0
				whoosh_sfx.play()
				tween_rotation()
				
				await get_tree().create_timer(0.2).timeout
				animation_player.play("clipboard")
				
				current_state = STATE.CHECKLIST
				await get_tree().create_timer(0.5).timeout
				turning = false
	
func tween_rotation() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "rotation_degrees:y", target_rotation, 0.3)
	
func _take_health() -> void:
	health_animation_player.play("hurt")
	EventBus.health += 1
	health_text.text = str(EventBus.health) + " / 10"
	
	if current_state == STATE.CAMERA:
		await health_animation_player.animation_finished
		camera_effect.visible = true
		
	#health_overlay_val += 0.1
	#health_overlay.material.set_shader_parameter("damage_intensity", health_overlay_val)
	
	if EventBus.health < 5:
		health_text.modulate = "ffffff"
	if EventBus.health >= 5 and EventBus.health < 8:
		health_text.modulate = "ecee6d"
	elif EventBus.health >= 8:
		health_text.modulate = "e55050"
		
	if EventBus.health == 10:
		EventBus._restart_values()
		SceneTransition.game_over()

#Day Timer
func _on_timer_timeout() -> void:
	EventBus.time += 1
	
	if EventBus.time >= 8 and EventBus.time <= 11:
		EventBus.meridiem = "AM"
	else:
		EventBus.meridiem = "PM"
		
		if EventBus.time == 13:
			EventBus.time -= 12
			
	time_label.text = str(EventBus.time) + " " + str(EventBus.meridiem)
	
	if EventBus.time == 10 or EventBus.time == 12 or EventBus.time == 2 or EventBus.time == 4 or EventBus.time == 5:
		SceneTransition.load_scene("uid://blef2j7xrd4os")

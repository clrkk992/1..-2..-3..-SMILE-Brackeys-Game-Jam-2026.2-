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
@onready var buttons: Node2D = $UI/Control/Buttons
@onready var forward_button: Area2D = $UI/Control/Buttons/UpButton
@onready var left_button: Area2D = $UI/Control/Buttons/LeftButton
@onready var right_button: Area2D = $UI/Control/Buttons/RightButton
@onready var back_button: Area2D = $UI/Control/Buttons/ButtonDown

enum TYPE {
	PLAYER,
	VOID
}

@export var char_list: Array[Sprite3D] = []
@export var type = TYPE.PLAYER

enum STATE {
	CENTER,
	CAMERA,
	CHECKLIST,
	LAPTOP
}

const DEFAULT_ROTATION := 0.0
const LAPTOP_ROTATION := 90.0
const CHECKLIST_ROTATION := -90.0

var current_state = STATE.CAMERA
var target_rotation := DEFAULT_ROTATION

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
	animation_player.play("camera")
	camera_effect.visible = true
	
	await get_tree().create_timer(0.5).timeout
	
	if type == TYPE.PLAYER:
		turning = false
		
		buttons.visible = true
		update_buttons()
		
func _input(event): 
	if event.is_action_pressed("move_forward"): 
		move_forward() 
	elif event.is_action_pressed("move_back"): 
		move_back() 
	elif event.is_action_pressed("move_left"): 
		move_left() 
	elif event.is_action_pressed("move_right"): 
		move_right()
		
func _on_up_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		move_forward()
	
func _on_down_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		move_back()
	
func _on_left_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		move_left()
	
func _on_right_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		move_right()
	
func update_buttons(): 
	# Hide everything first 
	forward_button.visible = false 
	back_button.visible = false 
	left_button.visible = false 
	right_button.visible = false
	
	match current_state: 
		STATE.CENTER: 
			forward_button.visible = true 
			left_button.visible = true 
			right_button.visible = true 
			
		STATE.CAMERA: 
			back_button.visible = true 
			
		STATE.CHECKLIST: 
			back_button.visible = true 
			left_button.visible = true 
			
		STATE.LAPTOP: 
			back_button.visible = true 
			right_button.visible = true
		
func move_forward(): 
	if turning: 
		return 
		
	match current_state: 
		STATE.CENTER: 
			animation_player.play("camera") 
			current_state = STATE.CAMERA
			
			update_buttons()
			
func move_back(): 
	if turning: 
		return 
		
	match current_state: 
		STATE.CAMERA: 
			animation_player.play_backwards("camera") 
			await animation_player.animation_finished 
			
			current_state = STATE.CENTER 
			
			update_buttons()
			
		STATE.CHECKLIST: 
			animation_player.play_backwards("clipboard") 
			await animation_player.animation_finished 
			
			target_rotation = DEFAULT_ROTATION 
			tween_rotation() 
			whoosh_sfx.play() 
			
			current_state = STATE.CENTER 
			
			update_buttons()
			
		STATE.LAPTOP: 
			target_rotation = DEFAULT_ROTATION 
			tween_rotation() 
			whoosh_sfx.play() 
			
			current_state = STATE.CENTER
			
			update_buttons()
			
func move_left(): 
	if turning: 
		return 
		
	match current_state: 
		STATE.CENTER: 
			target_rotation = LAPTOP_ROTATION 
			tween_rotation() 
			whoosh_sfx.play() 
			current_state = STATE.LAPTOP 
			
			update_buttons()
			
		STATE.CAMERA: 
			turning = true 
			
			animation_player.play_backwards("camera") 
			await animation_player.animation_finished 
			
			target_rotation = LAPTOP_ROTATION 
			whoosh_sfx.play() 
			tween_rotation() 
			
			current_state = STATE.LAPTOP
			await get_tree().create_timer(0.5).timeout 
			turning = false 
			
			update_buttons()
			
		STATE.CHECKLIST: 
			turning = true 
			
			animation_player.play_backwards("clipboard") 
			await animation_player.animation_finished 
			
			target_rotation = DEFAULT_ROTATION 
			whoosh_sfx.play() 
			tween_rotation() 
			
			animation_player.play("camera") 
			current_state = STATE.CAMERA 
			await get_tree().create_timer(0.5).timeout 
			turning = false
			
			update_buttons()
			
func move_right(): 
	if turning: 
		return 
		
	match current_state: 
		STATE.CENTER: 
			target_rotation = CHECKLIST_ROTATION 
			tween_rotation() 
			whoosh_sfx.play() 
			
			await get_tree().create_timer(0.2).timeout 
			
			animation_player.play("clipboard") 
			current_state = STATE.CHECKLIST 
			
			update_buttons()
			
		STATE.CAMERA: 
			turning = true 
			animation_player.play_backwards("camera") 
			await animation_player.animation_finished 
			
			target_rotation = CHECKLIST_ROTATION 
			whoosh_sfx.play() 
			tween_rotation() 
			
			animation_player.play("clipboard") 
			current_state = STATE.CHECKLIST 
			
			await get_tree().create_timer(0.5).timeout 
			turning = false 
			
			update_buttons()
			
		STATE.LAPTOP: 
			turning = true 
			
			target_rotation = DEFAULT_ROTATION 
			whoosh_sfx.play() 
			tween_rotation() 
			
			animation_player.play("camera") 
			current_state = STATE.CAMERA 
			
			await get_tree().create_timer(0.5).timeout 
			turning = false
			
			update_buttons()
	
func tween_rotation() -> void:
	var tween = create_tween()

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		camera,
		"rotation_degrees:y",
		target_rotation,
		0.3
	)
	
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

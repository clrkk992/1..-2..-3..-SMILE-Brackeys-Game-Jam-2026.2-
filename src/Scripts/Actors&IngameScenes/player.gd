extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var whoosh_sfx: AudioStreamPlayer3D = $WhooshSFX

@onready var camera_outline: MeshInstance3D = %camera_outline
@onready var static_effect: ColorRect = %StaticEffect
@onready var camera_timer: Timer = %CameraTimer

@onready var box_outline: MeshInstance3D = %box_outline
@onready var back: Button = %BackButton

@onready var object_touch_camera: Area3D = $ObjectTouchCamera
@onready var object_touch_laptop: Area3D = $ObjectTouchLaptop

@export var char_list: Array[Sprite3D] = []

enum STATE {
	CENTER,
	CAMERA,
	LAPTOP
}

var current_state = STATE.CENTER
var turning := false

func _ready() -> void:
	EventBus.scene_started.connect(_scene_started)
	
	_show_dialogue()
	_show_char_list()
	
func _scene_started() -> void:
	animation_player.play("clipboard")
	
func _show_dialogue() -> void:
	var dialogue_resource = preload("res://src/Dialogues/main.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "dialogue_" + str(EventBus.dialogue_num))
	EventBus.dialogue_num += 1
	
func _show_char_list() -> void:
	if EventBus.time == 8 or EventBus.time == 10 or EventBus.time == 12 or EventBus.time == 2 or EventBus.time == 4 or EventBus.time == 5:
		for i in range(EventBus.char_list_index + 1):
			char_list[i].randomize_char_clipboard.emit()
		if EventBus.char_list_index <= 5:
			EventBus.char_list_index += 1
		
func _input(event):
	if current_state == STATE.CENTER:
		if event.is_action_pressed("move_forward"):
			move_to("CAMERA")
			
		elif event.is_action_pressed("move_left"):
			move_to("LAPTOP")
		
	if event.is_action_pressed("move_back"): 
		move_back()
		
func move_to(state: String): 
	if turning: 
		return 
		
	turning = true
	
	if state == "CAMERA":
		current_state = STATE.CAMERA
	elif state == "LAPTOP":
		current_state = STATE.LAPTOP
	
	match current_state: 
		STATE.CAMERA:
			animation_player.play_backwards("clipboard")
			await animation_player.animation_finished
			
			whoosh_sfx.play()
			
			animation_player.play("camera") 
			object_touch_camera.input_ray_pickable = false
			await animation_player.animation_finished
			back.visible = true
			
			turning = false
			
		STATE.LAPTOP:
			animation_player.play_backwards("clipboard")
			await animation_player.animation_finished 
			
			whoosh_sfx.play()
			
			animation_player.play("laptop&buttons")
			object_touch_laptop.input_ray_pickable = false
			await animation_player.animation_finished
			back.visible = true
			
			turning = false
			
func move_back(): 
	if turning: 
		return 
	
	turning = true
	
	match current_state: 
		STATE.CAMERA: 
			current_state = STATE.CENTER
			
			back.visible = false
			animation_player.play_backwards("camera") 
			object_touch_camera.input_ray_pickable = true
			whoosh_sfx.play()
			
			await animation_player.animation_finished 
			
			animation_player.play("clipboard")
			
			turning = false
			
		STATE.LAPTOP: 
			current_state = STATE.CENTER
			
			back.visible = false
			animation_player.play_backwards("laptop&buttons")
			object_touch_laptop.input_ray_pickable = true
			whoosh_sfx.play()
			
			await animation_player.animation_finished 
			
			animation_player.play("clipboard")
			
			turning = false

func _on_camera_timer_timeout() -> void:
	if EventBus.time >= 2:
		var num := randi_range(0, 10)
			
		if num >= 5:
			EventBus.camera_triggered = false
			static_effect.visible = false
			if current_state == STATE.CAMERA:
				move_back()

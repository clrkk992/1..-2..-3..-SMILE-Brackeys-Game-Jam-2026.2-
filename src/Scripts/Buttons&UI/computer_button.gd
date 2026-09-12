extends Area3D

@onready var label: Label3D = $Label3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var outline: MeshInstance3D = $Label3D/Outline

@onready var select_sfx: AudioStreamPlayer3D = $SelectSFX
@onready var rising_sfx: AudioStreamPlayer3D = $RisingSFX
@onready var success: AudioStreamPlayer3D = $Success

enum COLOR {
	WHITE,
	PURPLE,
	BLUE,
	RED,
	ORANGE
}

enum FIX {
	LIGHTS,
	CAMERA
}

@export var fix := FIX.LIGHTS

#long press
var hold_time: float = 0.0
var required_hold_time: float = 2.3
var is_holding: bool = false

func _ready() -> void:
	EventBus.lights_triggered = true
	EventBus.camera_triggered = true
	
	match fix:
		FIX.LIGHTS:
			label.text = "LIGHTS"
		FIX.CAMERA:
			label.text = "CAMERA"

	animation_player.play("progress_bar_complete")

func _on_mouse_entered() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3(21.0, 21.0, 21.0), 0.15)
	outline.visible = true
	select_sfx.pitch_scale = 2.0
	select_sfx.volume_db = -40.0
	select_sfx.play()

func _on_mouse_exited() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3(20.0, 20.0, 20.0), 0.15)
	outline.visible = false
	
	_stop_holding()

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		
		if event.is_pressed():
			if fix == FIX.LIGHTS and EventBus.lights_triggered:
				return
				
			if fix == FIX.CAMERA and EventBus.camera_triggered:
				return
				
			is_holding = true
			hold_time = 0.0
			EventBus.lights_triggered = false
			animation_player.play("progress_bar")
			rising_sfx.play()
			
		elif event.is_released():
			_stop_holding()
			rising_sfx.stop()

func _stop_holding() -> void:
	if is_holding:
		is_holding = false
		hold_time = 0.0
		check_if_triggered()
			
func check_if_triggered() -> void:
	match fix:
		FIX.LIGHTS:
			if !EventBus.lights_triggered:
				animation_player.play("RESET")
				
		FIX.CAMERA:
			if !EventBus.camera_triggered:
				animation_player.play("RESET")
			
func shake_anim() -> void:
	var tween = create_tween()
	
	var squash_scale = Vector3(21.75, 21.7, 21.0)
	var normal_scale = Vector3(21.0, 21.0, 21.0)
	
	tween.tween_property(label, "scale", squash_scale, 0.06)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
		
	tween.tween_property(label, "scale", normal_scale, 0.35)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	if !is_holding:
		check_if_triggered()
		return
		
	hold_time += delta
	
	if hold_time >= required_hold_time:
		is_holding = false
		hold_time = 0.0
		
		success.play()
		rising_sfx.stop()
		shake_anim()
		animation_player.play("progress_bar_complete")
		
		if fix == FIX.LIGHTS:
			EventBus.lights_triggered = true
		elif fix == FIX.CAMERA:
			EventBus.camera_triggered = true

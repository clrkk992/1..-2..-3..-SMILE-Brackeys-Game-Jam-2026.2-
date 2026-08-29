extends Area3D

@onready var label: Label3D = $Label3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var color_bar: MeshInstance3D = %ColorBar
@onready var select_sfx: AudioStreamPlayer3D = $SelectSFX
@onready var rising_sfx: AudioStreamPlayer3D = $RisingSFX

enum STATE {
	CLICK,
	LONG_PRESS
}

enum COLOR {
	WHITE,
	PURPLE,
	BLUE,
	RED,
	ORANGE
}

@export var label_text: String
@export var current_state := STATE.CLICK

#long press
var hold_time: float = 0.0
var required_hold_time: float = 2.3
var is_holding: bool = false
var triggered: bool = true

#sequential click
var press_count := 0
var current_color := COLOR.WHITE
var color := "ffffff"

func _ready() -> void:
	label.text = label_text
	if current_state == STATE.LONG_PRESS:
		animation_player.play("progress_bar_complete")
	elif current_state == STATE.CLICK:
		color_bar.visible = true

func _on_mouse_entered() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3(21.0, 21.0, 21.0), 0.15)
	select_sfx.pitch_scale = 2.0
	select_sfx.volume_db = -40.0
	select_sfx.play()

func _on_mouse_exited() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3(20.0, 20.0, 20.0), 0.15)
	if !triggered:
		animation_player.play("RESET")

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if current_state == STATE.LONG_PRESS:
			if event.is_pressed() and !triggered:
				is_holding = true
				hold_time = 0.0
				triggered = false
				animation_player.play("progress_bar")
				rising_sfx.play()
			elif event.is_released():
				_stop_holding()
				rising_sfx.stop()
				
		elif current_state == STATE.CLICK:
			var mat: StandardMaterial3D = color_bar.get_active_material(0).duplicate()
			
			if event.is_pressed():
				press_count += 1
				shake_anim()
				select_sfx.pitch_scale = 5.0
				select_sfx.volume_db = -20.0
				select_sfx.play()
				
				if press_count == 0:
					change_color(label, mat, 
					"color: white           ", "ffffff", COLOR.WHITE)
				elif press_count == 1:
					change_color(label, mat, 
					"color: purple         ", "c3578a", COLOR.PURPLE)
				elif press_count == 2:
					change_color(label, mat, 
					"color: blue              ", "60ffff", COLOR.BLUE)
				elif press_count == 3:
					change_color(label, mat, 
					"color: red                ", "e55050", COLOR.RED)
				elif press_count == 4:
					change_color(label, mat, 
					"color: orange         ", "ff7c00", COLOR.ORANGE)
					press_count = -1
				
				color_bar.set_surface_override_material(0, mat)

func _stop_holding() -> void:
	if is_holding:
		is_holding = false
		hold_time = 0.0
		if !triggered:
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

func change_color(_label: Label3D, _mat: StandardMaterial3D, text : String, _color: String, color_state: COLOR) -> void:
	_label.text = text
	_mat.albedo_color = _color
	_mat.emission = _color
	color = _color
	
	current_color = color_state

func _process(delta: float) -> void:
	if current_state == STATE.LONG_PRESS:
		if is_holding and !triggered:
			hold_time += delta
			if hold_time >= required_hold_time:
				triggered = true
				shake_anim()
				rising_sfx.stop()
				animation_player.play("progress_bar_complete")
				select_sfx.pitch_scale = 5.0
				select_sfx.volume_db = 0.0
				select_sfx.play()
				
		elif !triggered:
			animation_player.play("RESET")

extends Area3D

@onready var text: Label3D = $Label3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var hold_time: float = 0.0
var required_hold_time: float = 3.0
var is_holding: bool = false
var triggered: bool = true

func _on_mouse_entered() -> void:
	text.scale = Vector3(21.0, 21.0, 21.0)

func _on_mouse_exited() -> void:
	text.scale = Vector3(20.0, 20.0, 20.0)
	if !triggered:
		animation_player.play("RESET")

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and !triggered:
			is_holding = true
			hold_time = 0.0
			triggered = false
			animation_player.play("progress_bar")
		elif event.is_released():
			_stop_holding()

func _stop_holding() -> void:
	if is_holding:
		is_holding = false
		hold_time = 0.0
		if !triggered:
			animation_player.play("RESET")

func _process(delta: float) -> void:
	if is_holding and !triggered:
		hold_time += delta
		if hold_time >= required_hold_time:
			triggered = true
			animation_player.play("progress_bar_complete")
			
	elif !triggered:
		animation_player.play("RESET")

extends Node3D

@onready var outline: MeshInstance3D = %Outline
@onready var button: MeshInstance3D = $Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum STATE {
	COLOR_BUTTON,
	POWER_BUTTON
}

@export var color: String = "ffffff"
@export var current_state = STATE.COLOR_BUTTON

func _ready() -> void:
	match current_state:
		STATE.COLOR_BUTTON:
			if color == "ffffff":
				animation_player.play("pressed")
			else:
				animation_player.play("default")
				
		STATE.POWER_BUTTON:
			if color == "d20000":
				animation_player.play("pressed")
			else:
				animation_player.play("default")
				
	EventBus.physical_button_pressed.connect(_on_button_pressed)
	
	var mat: StandardMaterial3D = button.get_active_material(0).duplicate()
	mat.albedo_color = color
	button.set_surface_override_material(0, mat)

func _on_area_3d_mouse_entered() -> void:
	outline.visible = true

func _on_area_3d_mouse_exited() -> void:
	outline.visible = false

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		match current_state:
			STATE.COLOR_BUTTON:
				EventBus.physical_button_pressed.emit(color, true)
			STATE.POWER_BUTTON:
				EventBus.physical_button_pressed.emit(color, false)
		
func _on_button_pressed(_color: String, _color_button_ba: bool) -> void:
	match current_state:
		STATE.COLOR_BUTTON:
			if _color_button_ba:
				if color == _color:
					animation_player.play("pressed")
				else:
					animation_player.play("default")
			
		STATE.POWER_BUTTON:
			if !_color_button_ba:
				if color == _color:
					animation_player.play("pressed")
				else:
					animation_player.play("default")

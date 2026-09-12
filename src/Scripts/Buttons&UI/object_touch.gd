extends Area3D

@export var outline: MeshInstance3D
@export var player: Node3D
@export var move_to: String

func _on_area_3d_mouse_entered() -> void:
	outline.visible = true

func _on_area_3d_mouse_exited() -> void:
	outline.visible = false

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		player.move_to(move_to)

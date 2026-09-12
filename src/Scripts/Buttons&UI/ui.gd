extends CanvasLayer

@onready var camera_animation_player: AnimationPlayer = %CameraAnimationPlayer
@onready var health_animation_player: AnimationPlayer = %HealthAnimationPlayer
@onready var health_text: Label3D = %Health
@onready var camera_effect: ColorRect = %CameraEffect

@export var player: Node3D

func _ready() -> void:
	EventBus.take_health.connect(_take_health)
	EventBus.camera_flash.connect(play_camera_flash)
	
func _on_camera_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		EventBus.camera_pressed.emit()
		
func play_camera_flash() -> void:
	camera_animation_player.play("camera_flash")
		
func _on_back_button_pressed() -> void:
	player.move_back()
		
func _take_health() -> void:
	health_animation_player.play("hurt")
	EventBus.health += 1
	health_text.text = str(EventBus.health) + " / 10"
	
	if player.current_state == player.STATE.CAMERA:
		await health_animation_player.animation_finished
		camera_effect.visible = true
	
	if EventBus.health < 5:
		health_text.modulate = "ffffff"
	if EventBus.health >= 5 and EventBus.health < 8:
		health_text.modulate = "ecee6d"
	elif EventBus.health >= 8:
		health_text.modulate = "e55050"
		
	if EventBus.health == 10:
		EventBus._restart_values()
		SceneTransition.game_over()

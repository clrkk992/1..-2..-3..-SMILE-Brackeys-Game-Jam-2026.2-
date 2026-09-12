extends Node3D

@onready var player: Node3D = $Player

@onready var current_character: Node3D = null

@onready var characters_spawn_point: Marker3D = $CharactersSpawnPoint
@onready var new_character_instance := preload("uid://vd7ty0jdgnb2")

@onready var light: OmniLight3D = %OmniLight3D
@onready var sun: DirectionalLight3D = $Sun

@onready var camera_shutter_sfx: AudioStreamPlayer3D = %CameraShutterSFX

@onready var light_off_sfx: AudioStreamPlayer3D = %LightOffSFX
@onready var light_timer: Timer = $LightTimer

var changing_character := false
var player_color := "ffffff"

var sun_settings := {
	8: {
		"rotation": Vector3(-6.0, -91.9, 12.3),
		"color": Color("ffffb2")
	},
	10: {
		"rotation": Vector3(-6.0, -101.5, 12.3),
		"color": Color("ffffb2")
	},
	12: {
		"rotation": Vector3(-6.0, -112.9, 12.3),
		"color": Color("ffff7d")
	},
	2: {
		"rotation": Vector3(-16.4, 85.0, 16.4),
		"color": Color("ffc57d")
	},
	4: {
		"rotation": Vector3(-16.4, 101.6, 16.4),
		"color": Color("ff9162")
	}
}

func _ready() -> void:
	EventBus.lights_triggered = true

	EventBus.character_finished.connect(_on_spawn_new_char)
	EventBus.physical_button_pressed.connect(_on_physical_button_pressed)
	EventBus.camera_pressed.connect(_on_camera_pressed)
	
	if sun_settings.has(EventBus.time):
		var settings = sun_settings[EventBus.time]

		sun.rotation_degrees = settings["rotation"]
		sun.light_color = settings["color"]
	
func _physics_process(_delta: float) -> void:
	#long press button triggered
	if EventBus.lights_triggered:
		light.light_energy = 1.0
	
func _on_camera_pressed() -> void:
	if player.current_state != player.STATE.CAMERA:
		return

	if !EventBus.lights_triggered:
		return

	if !EventBus.spawn_chars_enabled:
		return

	if current_character.animation_finished and !changing_character:
		changing_character = true #makes sure that no other chars spawn
		
		EventBus.camera_flash.emit()
		await get_tree().create_timer(0.5).timeout
		camera_shutter_sfx.play()
		
		check_character_color()
		
		_on_spawn_new_char()
				
func _on_physical_button_pressed(color: String, _color_button_ba: bool):
	if _color_button_ba:
		player_color = color
		light.light_color = color
	
func check_character_color() -> void:
	var character_color = current_character.required_color
	
	if player_color != character_color:
		EventBus.change_emote_angry.emit()

#checks to make sure its safe to spawn a new char
func _on_spawn_new_char() -> void:
	changing_character = true
	
	if is_instance_valid(current_character):
		current_character.walk_out()
		
	spawn_new_character()
	
	changing_character = false
	
func spawn_new_character() -> void:
	if EventBus.spawn_chars_enabled:
		var new_character := new_character_instance.instantiate()
		add_child(new_character)
		
		new_character.global_position = characters_spawn_point.global_position
		current_character = new_character

		new_character.walk_in()

#Light Timer
func _on_light_timer_timeout() -> void:
	if EventBus.spawn_chars_enabled:
		var num := randi_range(0, 10)
		
		if num >= 5:
			light.light_energy = 0.0
			EventBus.lights_triggered = false
			light_off_sfx.play()

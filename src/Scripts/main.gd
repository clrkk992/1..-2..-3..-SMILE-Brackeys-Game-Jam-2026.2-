extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player: Node3D = $Player
@onready var current_character: Node3D = null
@onready var characters_spawn_point: Marker3D = $CharactersSpawnPoint
@onready var new_character_instance := preload("uid://vd7ty0jdgnb2")
@onready var cursor: Sprite2D = %Cursor
@onready var light: OmniLight3D = %OmniLight3D
@onready var sun: DirectionalLight3D = $Sun
@onready var camera_shutter_sfx: AudioStreamPlayer3D = %CameraShutterSFX
@onready var light_off_sfx: AudioStreamPlayer3D = %LightOffSFX
@onready var light_timer: Timer = $LightTimer

@export var sun_gradient: Gradient

var changing_character := false

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
	
	if sun_settings.has(EventBus.time):
		var settings = sun_settings[EventBus.time]

		sun.rotation_degrees = settings["rotation"]
		sun.light_color = settings["color"]
	
func _physics_process(_delta: float) -> void:
	#long press button triggered
	if EventBus.lights_triggered:
		light.light_energy = 1.0
		
	#sequential button triggered
	light.light_color = player.color_button.color
	
func _input(event: InputEvent) -> void:
	if player.current_state == player.STATE.CAMERA and EventBus.lights_triggered:
			if EventBus.spawn_chars_enabled:
				if event.is_action_pressed("click") and !changing_character:
						if current_character.animation_finished:
							changing_character = true #makes sure that no other chars spawn
							
							animation_player.play("camera_flash")
							await animation_player.animation_finished
							camera_shutter_sfx.play()
							
							check_character_color()
							
							_on_spawn_new_char()
				
func check_character_color() -> void:
	var player_color = player.color_button.color
	var character_color = current_character.required_color
	
	if player_color != character_color:
		EventBus.change_emote_angry.emit()

#checks to make sure its safe to spawn a new char
func _on_spawn_new_char() -> void:
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
		
		for character in EventBus.character_list.values():
			if character["sprites"] == new_character.randomizer:
				new_character.required_color = character["colors"]
				break

		new_character.walk_in()

#Light Timer
func _on_light_timer_timeout() -> void:
	if EventBus.spawn_chars_enabled:
		var num := randi_range(0, 10)
		
		if num >= 5:
			light.light_energy = 0.0
			EventBus.lights_triggered = false
			light_off_sfx.play()

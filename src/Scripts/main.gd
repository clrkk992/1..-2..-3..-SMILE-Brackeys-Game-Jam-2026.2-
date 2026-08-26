extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player: Node3D = $Player
@onready var current_character: Node3D = null
@onready var characters_spawn_point: Marker3D = $CharactersSpawnPoint
@onready var new_character_instance := preload("uid://vd7ty0jdgnb2")
@onready var cursor: Sprite2D = %Cursor
@onready var time_label: Label = %Time
@onready var light: OmniLight3D = %OmniLight3D

var changing_character := false

var time:= 8
var meridiem := "AM"

func _ready() -> void:
	spawn_new_character()
	EventBus.character_finished.connect(_on_spawn_new_char)
	
func _physics_process(_delta: float) -> void:
	#long press button triggered
	if player.light_button.triggered == true:
		light.light_energy = 1.0
		
	#sequential button triggered
	if player.color_button.current_color == player.color_button.COLOR.WHITE:
		light.light_color = "ffffff"
	elif player.color_button.current_color == player.color_button.COLOR.RED:
		light.light_color = "ff0000"
	elif player.color_button.current_color == player.color_button.COLOR.GREEN:
		light.light_color = "00ff61"
	
func _input(event: InputEvent) -> void:
	if player.current_state == player.STATE.CAMERA and player.light_button.triggered:
		if event.is_action_pressed("click") and !changing_character:
			if current_character.animation_finished:
				animation_player.play("camera_flash")
				await animation_player.animation_finished
				
				_on_spawn_new_char()
				
#checks to make sure its safe to spawn a new char
func _on_spawn_new_char() -> void:
	if changing_character:
		return
		
	changing_character = true
	
	if is_instance_valid(current_character):
		current_character.walk_out()
		
	spawn_new_character()
	
	changing_character = false
	
func spawn_new_character() -> void:
	var new_character := new_character_instance.instantiate()
	add_child(new_character)
	
	new_character.global_position = characters_spawn_point.global_position
	current_character = new_character
	new_character.walk_in()

#Day Timer
func _on_timer_timeout() -> void:
	time += 1
	
	if time >= 8 and time <= 11:
		meridiem = "AM"
	else:
		meridiem = "PM"
		
		if time == 13:
			time -= 12
			
	time_label.text = str(time) + " " + str(meridiem)
	
	if time == 5:
		SceneTransition.reload_scene()

#Light Timer
func _on_light_timer_timeout() -> void:
	var num := randi_range(0, 10)
	
	if num >= 5:
		light.light_energy = 0.0
		player.light_button.triggered = false

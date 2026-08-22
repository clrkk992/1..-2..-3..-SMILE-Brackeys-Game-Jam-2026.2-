extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player: Node3D = $Player
@onready var current_character: Node3D = null
@onready var characters_spawn_point: Marker3D = $CharactersSpawnPoint
@onready var new_character_instance := preload("uid://vd7ty0jdgnb2")
@onready var cursor: Sprite2D = %Cursor
@onready var time_label: Label = %Time
@onready var light: OmniLight3D = %OmniLight3D

var time:= 8
var meridiem := "AM"

func _ready() -> void:
	spawn_new_character()
	
func _input(event: InputEvent) -> void:
	if player.current_state == player.STATE.CAMERA:
		if event.is_action_pressed("click"):
			if current_character.animation_finished:
				animation_player.play("camera_flash")
				
				await animation_player.animation_finished
				
				if is_instance_valid(current_character):
					current_character.walk_out()
					
				spawn_new_character()

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

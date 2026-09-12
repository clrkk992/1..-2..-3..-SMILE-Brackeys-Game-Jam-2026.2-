extends Node

#General
signal character_finished #character timer is done

signal camera_pressed
signal camera_flash

signal change_emote_angry
signal take_health

signal physical_button_pressed(color: String, color_button_ba: bool)

var character_list: Dictionary = {}
var char_list_index := 1

var time := 8
var meridiem := "AM"

var lights_triggered := true
var camera_triggered := true

var changed_scene := false

var health := 0

var computer_battery := 100.0

#tutorial
signal scene_started
var spawn_chars_enabled := false

#Dialogues
signal show_wife(show: bool)
var dialogue_num := 1

func _restart_values() -> void:
	char_list_index = 1
	character_list = {}
	time = 8
	meridiem = "AM"
	lights_triggered = true
	changed_scene = false
	health = 0
	computer_battery = 100.0

	spawn_chars_enabled = false

	dialogue_num = 1

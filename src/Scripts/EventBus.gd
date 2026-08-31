extends Node

#General
signal character_finished #character timer is done
signal change_emote_angry
signal take_health

var character_list: Dictionary = {}
var char_list_index := 1
var time := 8
var meridiem := "AM"
var lights_triggered := true
var changed_scene := false
var health := 0

#tutorial
signal tutorial_started
var spawn_chars_enabled := false

#Dialogues
var remove_no_one := false
var dialogue_num := 1

func _restart_values() -> void:
	char_list_index = 1
	character_list = {}
	time = 8
	meridiem = "AM"
	lights_triggered = true
	changed_scene = false
	health = 0

	spawn_chars_enabled = false

	remove_no_one = false
	dialogue_num = 1

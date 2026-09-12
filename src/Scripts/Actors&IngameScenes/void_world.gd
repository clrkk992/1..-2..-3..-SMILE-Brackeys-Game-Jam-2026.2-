extends Node3D

@onready var wife: Sprite3D = %Wife

func _ready() -> void:
	EventBus.show_wife.connect(_show_wife)
		
	var dialogue_resource = preload("res://src/Dialogues/main.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "dialogue_" + str(EventBus.dialogue_num))
	EventBus.dialogue_num += 1

func _show_wife(_show: bool) -> void:
	if !_show:
		wife.visible = false
	else:
		wife.visible = true

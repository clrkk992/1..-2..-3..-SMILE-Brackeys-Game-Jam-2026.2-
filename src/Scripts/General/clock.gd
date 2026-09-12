extends Node3D

@onready var time_label: Label3D = %Label3D

func _ready() -> void:
	time_label.text = str(EventBus.time) + " " + str(EventBus.meridiem)

#Day Timer
func _on_timer_timeout() -> void:
	EventBus.time += 1
	
	if EventBus.time >= 8 and EventBus.time <= 11:
		EventBus.meridiem = "AM"
	else:
		EventBus.meridiem = "PM"
		
		if EventBus.time == 13:
			EventBus.time -= 12
			
	time_label.text = str(EventBus.time) + " " + str(EventBus.meridiem)
	
	if EventBus.time == 10 or EventBus.time == 12 or EventBus.time == 2 or EventBus.time == 4 or EventBus.time == 5:
		SceneTransition.load_scene("uid://blef2j7xrd4os")

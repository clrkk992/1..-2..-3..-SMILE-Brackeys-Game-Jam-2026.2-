extends Node3D

@onready var computer_turn_off_screen: Node3D = %TurnOff
@onready var battery_timer: Timer = %BatteryTimer
@onready var battery: ProgressBar = %Battery
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	EventBus.physical_button_pressed.connect(turn_computer_on_or_off)
	battery.value = EventBus.computer_battery
	
	var fill_stylebox := battery.get_theme_stylebox("fill").duplicate()
	battery.add_theme_stylebox_override("fill", fill_stylebox)
	
	change_battery_color()
	
func _process(_delta: float) -> void:
	if computer_turn_off_screen.visible == false:
		if battery_timer.is_stopped():
			battery_timer.start()
	else:
		battery_timer.stop()
	
func turn_computer_on_or_off(_color: String, _color_button_ba: bool) -> void:
	if !_color_button_ba:
		if _color == "00ff00":
			computer_turn_off_screen.visible = false
		else:
			computer_turn_off_screen.visible = true

func _on_battery_timer_timeout() -> void:
	EventBus.computer_battery -= 20
	battery.value = EventBus.computer_battery
	
	change_battery_color()
	
	if battery.value == 0:
		animation_player.play("charging")
		await animation_player.animation_finished
		EventBus.computer_battery = 80
		battery.value = EventBus.computer_battery
	
func change_battery_color() -> void:
	var fill_stylebox := battery.get_theme_stylebox("fill") as StyleBoxFlat
	
	if battery.value > 40 and battery.value <= 100:
		fill_stylebox.bg_color = Color("00f215")
	elif battery.value > 20 and battery.value <= 40:
		fill_stylebox.bg_color = Color("ffff15")
	elif battery.value == 20:
		fill_stylebox.bg_color = Color("ff0015")

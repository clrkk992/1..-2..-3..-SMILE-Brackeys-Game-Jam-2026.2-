extends CanvasLayer

@onready var cursor: Sprite2D = %Cursor

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _physics_process(_delta: float) -> void:
	cursor.global_position = cursor.get_global_mouse_position()

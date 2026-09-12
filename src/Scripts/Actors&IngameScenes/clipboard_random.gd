extends Sprite3D

signal randomize_char_clipboard

@onready var color: MeshInstance3D = $Color

@export var id := 1

var texture_array: Array[String] = ["uid://vyam02dvt42h", "uid://ci4kj1fxqu1qt", "uid://dgf4kj7rvr0ls",
									"uid://bciep55utw26t", "uid://b5jsvkc8yrlft",
									"uid://871n2woymsbe", "uid://dfv61x7x3e63b", "uid://bg4u0nj5jjdpo",
									"uid://rgvtmlogtndb", "uid://crurbwd4vkjjd", "uid://doc0ggym6tpus",
									"uid://kmtkklxkorko", "uid://qlshvybhrdpa", "uid://dkgg61siqo7b0",
									"uid://bl8moebfqo0ps", "uid://rvam87g5l88k", "uid://c1f6y4ijv7xtj",
									"uid://bcyrr1fil6ucq"]

var color_array: Array[String] = ["c3578a", "60ffff", "e55050", "ff7c00"]

func _ready() -> void:
	randomize_char_clipboard.connect(_randomize_self)
	
func _randomize_self() -> void:
	self.visible = true
	var char_list = EventBus.character_list

	# Character already exists in EventBus
	if char_list.has(id):
		var saved_character = char_list[id]

		var char_randomizer: int = saved_character["sprites"]
		var saved_color: String = saved_character["colors"]

		var mat: StandardMaterial3D = color.get_active_material(0).duplicate()

		texture = load(texture_array[char_randomizer])
		mat.albedo_color = saved_color
		color.set_surface_override_material(0, mat)

		return

	# Character doesn't exist yet, so create it
	var char_randomizer := randi_range(0, 17)
	var color_randomizer := randi_range(0, 3)

	for _char in char_list.values():
		if _char == null:
			continue

		while _char["sprites"] == char_randomizer:
			char_randomizer = randi_range(0, 17)

	var selected_color := color_array[color_randomizer]

	var mat: StandardMaterial3D = color.get_active_material(0).duplicate()

	texture = load(texture_array[char_randomizer])
	mat.albedo_color = selected_color
	color.set_surface_override_material(0, mat)

	char_list[id] = {
		"sprites": char_randomizer,
		"colors": selected_color
	}

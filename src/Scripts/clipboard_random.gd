extends Sprite3D

@onready var color: MeshInstance3D = $Color

var texture_array: Array[String] = ["uid://vyam02dvt42h", "uid://ci4kj1fxqu1qt", "uid://dgf4kj7rvr0ls",
									"uid://bciep55utw26t", "uid://cllp5lg6gd255", "uid://b5jsvkc8yrlft",
									"uid://871n2woymsbe", "uid://dfv61x7x3e63b", "uid://bg4u0nj5jjdpo",
									"uid://rgvtmlogtndb", "uid://crurbwd4vkjjd", "uid://doc0ggym6tpus",
									"uid://kmtkklxkorko", "uid://qlshvybhrdpa", "uid://dkgg61siqo7b0",
									"uid://bl8moebfqo0ps", "uid://rvam87g5l88k", "uid://c1f6y4ijv7xtj",
									"uid://bcyrr1fil6ucq"]

var color_array: Array[String] = ["c3ff8a", "ecee6d", "e55050"]

func _ready() -> void:
	var char_randomizer = randi_range(0,18)
	texture = load(texture_array[char_randomizer])
	
	var color_randomizer = randi_range(0,2)
	var mat: StandardMaterial3D = color.get_active_material(0).duplicate()
	mat.albedo_color = color_array[color_randomizer]
	color.set_surface_override_material(0, mat)

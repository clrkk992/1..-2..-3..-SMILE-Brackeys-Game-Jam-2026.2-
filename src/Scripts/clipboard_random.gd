extends Sprite3D

@onready var color: MeshInstance3D = $Color

var texture_array: Array[String] = ["uid://vyam02dvt42h", "uid://ci4kj1fxqu1qt", "uid://dgf4kj7rvr0ls",
									"uid://bciep55utw26t", "uid://cllp5lg6gd255", "uid://b5jsvkc8yrlft",
									"uid://871n2woymsbe", "uid://dfv61x7x3e63b", "uid://bg4u0nj5jjdpo",
									"uid://rgvtmlogtndb", "uid://crurbwd4vkjjd", "uid://doc0ggym6tpus",
									"uid://kmtkklxkorko", "uid://qlshvybhrdpa", "uid://dkgg61siqo7b0",
									"uid://bl8moebfqo0ps", "uid://rvam87g5l88k", "uid://c1f6y4ijv7xtj",
									"uid://bcyrr1fil6ucq"]

var color_array: Array[String] = ["c3578a", "60ffff", "e55050", "ff7c00"]

func _ready() -> void:
	if self.visible == true:
		var char_randomizer = randi_range(0,18)
		var color_randomizer = randi_range(0,3)
		
		var char_list = EventBus.character_list
		
		for _char in char_list.values():
			if _char == null:
				return
				
			while _char["sprites"] == char_randomizer:
				char_randomizer = randi_range(0,18)
			
		var mat: StandardMaterial3D = color.get_active_material(0).duplicate()
		
		texture = load(texture_array[char_randomizer])
		mat.albedo_color = color_array[color_randomizer]
		color.set_surface_override_material(0, mat)
		
		var new_id = "character_" + str(char_list.size() + 1)
		char_list[new_id] = {"sprites": char_randomizer, "colors": color_array[color_randomizer]}

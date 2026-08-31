extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite: Sprite3D = %Sprite3D
@onready var bar_animation_player: AnimationPlayer = %BarAnimationPlayer
@onready var emotion: Sprite3D = %Emotion
@onready var emoji_sfx: AudioStreamPlayer3D = %EmojiSFX
@onready var angry_sfx: AudioStreamPlayer3D = %AngrySFX

var texture_array: Array[String] = ["uid://vyam02dvt42h", "uid://ci4kj1fxqu1qt", "uid://dgf4kj7rvr0ls",
									"uid://bciep55utw26t", "uid://b5jsvkc8yrlft",
									"uid://871n2woymsbe", "uid://dfv61x7x3e63b", "uid://bg4u0nj5jjdpo",
									"uid://rgvtmlogtndb", "uid://crurbwd4vkjjd", "uid://doc0ggym6tpus",
									"uid://kmtkklxkorko", "uid://qlshvybhrdpa", "uid://dkgg61siqo7b0",
									"uid://bl8moebfqo0ps", "uid://rvam87g5l88k", "uid://c1f6y4ijv7xtj",
									"uid://bcyrr1fil6ucq"]

var animation_finished: bool = false
var walk_in_interrupted: bool = false

var randomizer := 0
var required_color := "ffffff"

func _ready() -> void:
	EventBus.change_emote_angry.connect(change_emotion_angry)
	randomizer = randi_range(0,17)
	sprite.texture = load(texture_array[randomizer])

func walk_in() -> void:
	animation_finished = false
	
	animation_player.play("walk_in")
	await animation_player.animation_finished
	
	#don't spawn new char if there is already a character spawned
	if walk_in_interrupted:
		return
	
	animation_player.play("idle")
	animation_finished = true
	
	bar_animation_player.play("progress_bar")
	var finished_animation = await bar_animation_player.animation_finished

	if finished_animation != "progress_bar":
		return
	
	#don't spawn new char if there is already a character spawned
	if walk_in_interrupted:
		return
		
	#spawn new character after timed out
	EventBus.character_finished.emit()
	
func walk_out() -> void:
	walk_in_interrupted = true #makes sure that the walk_in won't continue
	animation_finished = false
	
	bar_animation_player.play("emotion_show")
	await bar_animation_player.animation_finished
	
	if emotion.region_rect == Rect2(20.0, 0.0, 11.084, 10.0):
		emoji_sfx.pitch_scale = 2.0
		emoji_sfx.play()
	elif emotion.region_rect == Rect2(31.9, 0.0, 11.084, 10.0):
		emoji_sfx.pitch_scale = 0.5
		emoji_sfx.play()
	elif emotion.region_rect == Rect2(44.0, 0.0, 11.084, 10.0):
		EventBus.take_health.emit()
		angry_sfx.play()
		
	animation_player.play("walk_out")
	await animation_player.animation_finished
	
	queue_free()
	animation_finished = true
	
func change_emotion_angry() -> void:
	emotion.region_rect = Rect2(44.0, 0.0, 11.084, 10.0)

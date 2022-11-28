extends Node

const sounds_path = "res://assets/sfx/%s.ogg"
const sounds := {
	"step": preload(sounds_path % "step"),
	"death": preload(sounds_path % "death"),
	"jump": preload(sounds_path % "jump"),
	"click": preload(sounds_path % "click"),
	"throw": preload(sounds_path % "woosh"),
}

@onready var sound_players := get_children()


func play(sound: String, volume_db := 0, pitch_scale := randf() + 0.4):
	for player in sound_players:
		if not player.playing:
			player.pitch_scale = pitch_scale
			player.volume_db = volume_db
			player.stream = sounds[sound]
			player.play()
			return
	print("sounds overflow, discrding")

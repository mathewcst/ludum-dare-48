extends Node


onready var music_player = $MainMusic


var theme_music = load("res://Audio/theme_loop.ogg")

var is_playing = true


func _ready() -> void:
	pass


func play_music() -> void:
	if is_playing:
		music_player.stream = theme_music
		music_player.play()


func stop_all() -> void:
	music_player.stop()
	music_player.stream = null

func toggle_mute() -> void:
	if is_playing:
		is_playing = false
		stop_all()
	else:
		is_playing = true
		play_music()

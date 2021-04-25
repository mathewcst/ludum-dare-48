extends Node


onready var music_player = $MainMusic


var theme_music = load("res://Audio/theme_loop.ogg")


func _ready() -> void:
	pass


func play_music() -> void:
	music_player.stream = theme_music
	music_player.play()

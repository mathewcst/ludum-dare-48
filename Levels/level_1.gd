extends Node2D

var custom_cursor = load("res://UI/Cursor/Cursor.png")


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(custom_cursor)
	
	MusicController.play_music()
	


func _on_PlayBtn_button_down() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().change_scene("res://Levels/level_1.tscn")


func _on_MuteBtn_button_down() -> void:
	MusicController.toggle_mute()


func _on_FullScreenBtn_button_down() -> void:
	OS.set_window_fullscreen(!OS.is_window_fullscreen())


func _on_QuitBtn_button_down() -> void:
	get_tree().quit()

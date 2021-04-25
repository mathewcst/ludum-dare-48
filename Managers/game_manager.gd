extends Node

signal player_initialised

var player

func _process(_delta: float) -> void:
	if not player:
		initialise_player()
		return


func initialise_player() -> void:
	player = get_tree().get_root().get_node("/root/World/Player")
	if not player:
		return

	emit_signal("player_initialised", player)

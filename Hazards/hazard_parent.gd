class_name Hazard
extends StaticBody2D

func _on_PlayerDettect_body_entered(body: Node) -> void:
	body.damage_player(1, global_position)

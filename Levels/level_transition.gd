extends Node2D

onready var animation = $CanvasLayer/AnimationPlayer


export var next_level_path: String

func _ready() -> void:
	animation.play("Out")


func _on_Area2D_body_entered(_body: Node) -> void:
	animation.play("In")


func change_scene() -> void:
	var _change = get_tree().change_scene(next_level_path)

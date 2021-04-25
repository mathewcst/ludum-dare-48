extends Hazard

onready var animation_player = $AnimationPlayer
onready var spawn_position = $Position2D

export var projectile: PackedScene
export var direction: Vector2
export var launch_interval: float = 2.5

func _ready() -> void:
	$ShootInterval.wait_time = launch_interval
	$ShootInterval.start()


func fire() -> void:
	animation_player.play("Fire")


func spawn_spear() -> void:
	var spear = projectile.instance()
	owner.add_child(spear)
	spear.change_direction(direction)
	spear.position = spawn_position.global_position
	spear.rotation = rotation


func _on_ShootInterval_timeout() -> void:
	fire()

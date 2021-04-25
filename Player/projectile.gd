extends Area2D

onready var sprite = $Sprite

var speed = 400
var bullet_range = 200

var direction = 1
var original_pos = Vector2.ZERO


func _physics_process(delta: float) -> void:
	position.x += speed * delta * direction
	
	
	if direction > 0:
		sprite.flip_h = false
		if position.x > original_pos.x + bullet_range:
			queue_free()
			
	elif direction < 0:
		sprite.flip_h = true
		if position.x < original_pos.x - bullet_range:
			queue_free()


func switch_direction(new_direction: int) -> void:
	direction = new_direction


func set_spawn_position(new_position: Vector2) -> void:
	original_pos = new_position


func _on_Projectile_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"):
		body.take_damage(1)
	
	queue_free()

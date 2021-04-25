extends Hazard

var direction = Vector2.ZERO
var speed = 100

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
func change_direction(new_direction: Vector2) -> void:
	direction = new_direction
	
func _on_PlayerDettect_body_entered(body: Node) -> void:
	
	if body.is_in_group("Player"):
		body.damage_player(1, global_position)
	
	queue_free()

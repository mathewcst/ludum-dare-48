extends KinematicBody2D

# ---- NODES
onready var idle_timer = $IdleTimer
onready var patrol_timer = $PatrolTimer

onready var edge_cast = $EdgeCast
onready var wall_cast = $WallCast

onready var sprite = $Sprite


# ---- INSTANCE VARS
export var move_speed: int = 40


# ---- MEMBER VARS
const ACCELERATION = 450
const FRICTION = 450
const UP = Vector2(0, -1)

var direction = 1
var velocity = Vector2.ZERO
var input_vector = Vector2(0,0)

var patrolling: bool = false


func _ready() -> void:
	patrol()


func _physics_process(delta: float) -> void:
	input_vector.x = direction
	
	if patrolling:
		
		if not edge_cast.is_colliding() or wall_cast.is_colliding():
			change_direction()
			
		velocity = velocity.move_toward(input_vector * move_speed, ACCELERATION * delta)
		
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	velocity = move_and_slide(velocity, UP)

func patrol() -> void:
	patrol_timer.start()
	patrolling = true


func idle() -> void:
	patrolling = false
	idle_timer.start()
	change_direction()
	

func change_direction() -> void:
	direction *= -1
	edge_cast.position.x *= -1
	wall_cast.position.x *= -1
	sprite.flip_h = !sprite.flip_h
	
	if direction > 0:
		wall_cast.rotation_degrees = 0
	elif direction < 0:
		wall_cast.rotation_degrees = 180

# ---- SIGNALS
func _on_PatrorlTimer_timeout() -> void:
	idle()


func _on_IdleTimer_timeout() -> void:
	patrol()

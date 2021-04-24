extends KinematicBody2D

# ---- NODES
onready var idle_timer = $IdleTimer
onready var patrol_timer = $PatrolTimer

onready var edge_cast = $EdgeCast
onready var wall_cast = $WallCast

onready var sprite = $AnimatedSprite


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
	sprite.play("Walk")
	patrol_timer.start()
	patrolling = true


func idle() -> void:
	sprite.play("Idle")
	patrolling = false
	idle_timer.start()
	
	randomize()
	var chance = rand_range(-1, 1)
	
	if chance > 0:
		chance = 1
	elif chance < 0:
		chance = -1
		
	change_direction(chance)
	

func change_direction(new_direction: int = 0) -> void:
	var previous_direction = direction
	
	if new_direction != 0:
		direction *= new_direction
	else:
		direction *= -1
	
	# If direction change, flip colliders and sprite
	if previous_direction != direction:
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


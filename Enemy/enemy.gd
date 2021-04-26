extends KinematicBody2D

# ---- NODES
onready var idle_timer = $IdleTimer
onready var patrol_timer = $PatrolTimer

onready var edge_cast = $EdgeCast
onready var wall_cast = $WallCast

onready var sprite = $AnimatedSprite
onready var hit_animation = $HitAnimation
onready var hit_timer = $HitTimer
onready var audio_player = $AudioStreamPlayer2D


# ---- INSTANCE VARS
export var move_speed: int = 40
export var chase_speed: int = 55
export var health:int = 2


# ---- MEMBER VARS
const ACCELERATION = 450
const FRICTION = 450
const GRAVITY = 120
const UP = Vector2(0, -1)

var direction = 1
var velocity = Vector2.ZERO
var input_vector = Vector2(0,0)

var patrolling: bool = false
var chasing: bool = false
var chase_body: KinematicBody2D = null

# ---- AUDIO
var hurt_sound = load("res://Audio/Enemy_Hurt.wav")


func _ready() -> void:
	patrol()


func _physics_process(delta: float) -> void:
	input_vector.x = direction
	
	if health <= 0:
		die()
	
	if patrolling:
		
		if not edge_cast.is_colliding() or wall_cast.is_colliding():
			change_direction()
			
		velocity = velocity.move_toward(input_vector * move_speed, ACCELERATION * delta)
		
	elif chasing:
		if not edge_cast.is_colliding() or wall_cast.is_colliding():
			change_direction()
			patrol()
		
		else:
			var chase_direction = position.direction_to(chase_body.position)
			chase(chase_direction.x)
			
			velocity = velocity.move_toward(Vector2(chase_direction.x, 0) * chase_speed, ACCELERATION * delta)
		
		
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	velocity = move_and_slide(velocity, UP)

func patrol() -> void:
	sprite.play("Walk")
	idle_timer.stop()
	patrol_timer.start()
	patrolling = true


func idle() -> void:
	sprite.play("Idle")
	patrolling = false
	patrol_timer.stop()
	idle_timer.start()
	velocity.x = 0
	
	randomize()
	var chance = rand_range(-1, 1)
	
	if chance > 0:
		chance = 1
	elif chance < 0:
		chance = -1
		
	change_direction(chance)
	

func chase(_direction: float) -> void:
	
	if _direction > 0:
		_direction = 1
	elif _direction < 0:
		_direction = -1
	
	
	patrol_timer.stop()
	idle_timer.stop()
	change_direction(_direction)

	

func change_direction(new_direction: int = 0) -> void:
	var previous_direction = direction
	
	if new_direction != 0:
		direction = new_direction
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


func take_damage(amount: int) -> void:
	audio_player.play()
	health -= amount
	hit_animation.play("Start")
	hit_timer.start()
	
	print(health)


func die() -> void:
	yield(audio_player, "finished")
	queue_free()
	
	

func chase_player(player: KinematicBody2D) -> void:
	chasing = true
	chase_body = player


func stop_chasing() -> void:
	velocity.x = 0
	chasing = false
	chase_body = null
	idle()


# ---- SIGNALS
func _on_PatrorlTimer_timeout() -> void:
	idle()


func _on_IdleTimer_timeout() -> void:
	patrol()



func _on_LineOfSight_body_entered(body: Node) -> void:
	chase_player(body)


func _on_LineOfSight_body_exited(body: Node) -> void:
	stop_chasing()


func _on_HitTimer_timeout() -> void:
	hit_animation.play("Stop")

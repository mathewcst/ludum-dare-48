extends KinematicBody2D

# ---- INSTANCE VARS
export var move_speed: int = 100
export var jump_height: int = 350


# ---- NODES
onready var sprite = $Sprite


# ---- MEMBER VARS
const ACCELARTION = 450
const FRICTION = 450
const GRAVITY = 20
const UP = Vector2(0, -1)

var velocity = Vector2.ZERO
var direction = 1
var jump_amount = 2

# ---- COYOTE JUMP
var jump_pressed_remember = 0
var jump_pressed_remember_timer = 0.2

var grounded_remember = 0
var grounded_remember_timer = 0.2


func _physics_process(delta: float) -> void:
	
	remember_grounded(delta)
	remember_jump(delta)
	
	if can_player_jump():
		grounded_remember = 0
		jump_pressed_remember = 0
		velocity.y -= jump_height
		jump_amount -= 1
	
	apply_gravity()
	
	velocity = move(delta)
	
	animations()


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("jump"):
		if not is_on_floor() and jump_amount > 0:
			grounded_remember = 0
			jump_pressed_remember = 0
			velocity.y -= jump_height
			jump_amount -= 1
	


func _get_inputs() -> Vector2:
	var input_vector = Vector2.ZERO
	
	var input_right = Input.get_action_strength("move_right")
	var input_left = Input.get_action_strength("move_left")
	
	input_vector.x = input_right - input_left
	
	return input_vector


func move(delta) -> Vector2:
	var input_vector = _get_inputs()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * move_speed, ACCELARTION * delta)
		
		if input_vector.x > 0:
			direction = 1
		elif input_vector.x < 0:
			direction = -1
		
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	return move_and_slide(velocity, UP)


func apply_gravity() -> void:
	velocity.y += GRAVITY


func can_player_jump() -> bool:
	return jump_pressed_remember > 0 and grounded_remember > 0 and jump_amount > 0


func remember_grounded(delta) -> void:
	grounded_remember -= delta
	
	if is_on_floor():
		jump_amount = 2
		grounded_remember = grounded_remember_timer

func remember_jump(delta) -> void:
	jump_pressed_remember -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_pressed_remember = jump_pressed_remember_timer


func animations() -> void:
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true

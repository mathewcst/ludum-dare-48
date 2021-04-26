extends KinematicBody2D

# ---- INSTANCE VARS
export var move_speed: int = 100
export var jump_height: int = 350
export var can_take_damage: bool = true
export var projectile: PackedScene


# ---- NODES
onready var sprite = $AnimatedSprite
onready var gun = $Gun
onready var muzzle = $Muzzle
onready var animation_player = $AnimationPlayer
onready var hit_animation = $HitAnimation
onready var camera = $PlayerCamera
onready var audio_player = $AudioStreamPlayer

onready var invencible_timer = $InvencibleTimer
onready var health_bar = $HBoxContainer
onready var bullets_bar = $VBoxContainer

# ---- MEMBER VARS
const ACCELARTION = 450
const FRICTION = 450
const GRAVITY = 20
const UP = Vector2(0, -1)

var velocity = Vector2.ZERO
var direction = 1
var jump_amount = 2
var double_jump_height = jump_height


# ---- AUDIO
var bullet_sound = load("res://Audio/Shooting.wav")
var hurt_sound = load("res://Audio/Hit_Hurt.wav")


# ---- STATS
var health = 4

# ---- COYOTE JUMP
var jump_pressed_remember = 0
var jump_pressed_remember_timer = 0.2

var grounded_remember = 0
var grounded_remember_timer = 0.2

# ---- SHOOT
var bullets = 5
var max_bullets = 10
var shoot_pressed_remember = 0
var shoot_pressed_remember_timer = 0.2

func _physics_process(delta: float) -> void:
	
	remember_grounded(delta)
	remember_jump(delta)
	remember_shoot(delta)
	
	if can_player_jump():
		grounded_remember = 0
		jump_pressed_remember = 0
		velocity.y -= double_jump_height
		jump_amount -= 1
	
	apply_gravity()
	
	velocity = move(delta)
	
	animations()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset"):
		var _reload = get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("jump"):
		if not is_on_floor() and jump_amount > 0:
			
			double_jump_height += GRAVITY + 30
			
			grounded_remember = 0
			jump_pressed_remember = 0
			velocity.y -= double_jump_height
			jump_amount -= 1
			
	if Input.is_action_just_pressed("fire"):
		shoot()
		
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://Levels/main_menu.tscn")
	


func _get_inputs() -> Vector2:
	var input_vector = Vector2.ZERO
	
	var input_right = Input.get_action_strength("move_right")
	var input_left = Input.get_action_strength("move_left")
	
	input_vector.x = input_right - input_left
	
	return input_vector


func move(delta) -> Vector2:
	var input_vector = _get_inputs()
	
	if input_vector != Vector2.ZERO:
		animation_player.play("Walk")
		velocity = velocity.move_toward(input_vector * move_speed, ACCELARTION * delta)
		
		if input_vector.x > 0:
			direction = 1
		elif input_vector.x < 0:
			direction = -1
		
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animation_player.play("Idle")
		
	if not is_on_floor():
		if velocity.y < 0:
			animation_player.play("Air")
		elif velocity.y > 0:
			animation_player.play("Fall")
		
	
	return move_and_slide(velocity, UP)


func damage_player(amount: int = 0, hit_position: Vector2 = Vector2.ZERO) -> void:
	var knockback = 200
	
	if health <= 0:
		die()
	
	if can_take_damage:
		audio_player.stream = hurt_sound
		audio_player.play()
		
		health -= amount
		can_take_damage = false
		
		hit_animation.play("Start")
		
		# Get hit direction
		if hit_position.x > position.x:
			# move left
			velocity.x -= knockback
		elif hit_position.x < position.x:
			# move right
			velocity.x += knockback
	
		# Move pleyer up a little bit
		velocity.y = -knockback
			
		invencible_timer.start()


func shoot() -> void:
	audio_player.stream = bullet_sound
	
	if shoot_pressed_remember < 0 and bullets > 0:
		audio_player.play()
		bullets -= 1
		var bullet = projectile.instance()
		owner.add_child(bullet)
		bullet.switch_direction(direction)
		bullet.position = muzzle.global_position
		bullet.set_spawn_position(muzzle.global_position)


func die() -> void:
	hit_animation.play("Stop")
	queue_free()
	get_tree().change_scene("res://Levels/main_menu.tscn")


# ---- HELPER FUNCTIONS
func apply_gravity() -> void:
	velocity.y += GRAVITY


func can_player_jump() -> bool:
	return jump_pressed_remember > 0 and grounded_remember > 0 and jump_amount > 0


func remember_grounded(delta) -> void:
	grounded_remember -= delta
	
	if is_on_floor():
		jump_amount = 2
		double_jump_height = jump_height
		grounded_remember = grounded_remember_timer

func remember_jump(delta) -> void:
	jump_pressed_remember -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_pressed_remember = jump_pressed_remember_timer


func remember_shoot(delta) -> void:
	shoot_pressed_remember -= delta
	
	if Input.is_action_just_pressed("fire") and shoot_pressed_remember < 0:
		shoot_pressed_remember = shoot_pressed_remember_timer


	
func animations() -> void:
	if direction > 0:
		sprite.flip_h = false
		gun.position.x = 8
		muzzle.position.x = 12
	elif direction < 0:
		sprite.flip_h = true
		gun.position.x = -8
		muzzle.position.x = -12
		
	
	for child in health_bar.get_child_count():
		health_bar.get_child(child).visible = health > child	
	
	for child in bullets_bar.get_child_count():
		bullets_bar.get_child(child).visible = bullets > child


# ---- SIGNALS

func _on_RoomDetector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Room"):
		var collision_shape = area.get_node('CollisionShape2D')
		var size = collision_shape.shape.extents * 2
		
		var view_size = get_viewport_rect().size
		
		if size.y < view_size.y:
			size.y = view_size.y
			
		if size.x < view_size.x:
			size.x = view_size.x
		
		camera.limit_top = collision_shape.global_position.y - size.y / 2
		camera.limit_left = collision_shape.global_position.x - size.x / 2
		
		camera.limit_bottom = camera.limit_top + size.y
		camera.limit_right = camera.limit_left + size.x
	


func _on_HitBox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hitbox"):
		damage_player(1, area.global_position)


func _on_InvencibleTimer_timeout() -> void:
	hit_animation.play("Stop")
	can_take_damage = true


func _on_BulletReplenishTimer_timeout() -> void:
	if bullets < max_bullets:
		bullets += 1

extends Hazard

onready var collision_shape = $CollisionShape2D
onready var player_dettect = $PlayerDettect/CollisionShape2D
onready var base = $Sprite
onready var spikes = $Sprite/Spikes


func _physics_process(delta: float) -> void:
	player_dettect.global_transform = spikes.global_transform
	collision_shape.global_transform = base.global_transform

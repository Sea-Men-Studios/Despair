extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var speed = 1.0
var target_velocity = Vector3.ZERO
func _ready() -> void:
	animation_player.play("walk")

func _process(delta: float) -> void:
	velocity = target_velocity
	position = position.move_toward(Vector3(0,0,0), delta * speed)
	var lookdir = atan2(-velocity.x, -velocity.z)
	rotation.y = lookdir

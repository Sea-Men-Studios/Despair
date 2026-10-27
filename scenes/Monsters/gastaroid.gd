extends Node3D
@onready var gastaroid: Node3D = $".."


@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"


func _ready() -> void:
	animation_player.play("walk")


func _process(_delta: float) -> void:
	gastaroid.rotation.y += 0.0001

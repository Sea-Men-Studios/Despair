extends Node3D
@onready var golem: Node3D = $".."


@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"


func _ready() -> void:
	animation_player.play("walkNormal")


func _process(_delta: float) -> void:
	golem.rotation.y += 0.001

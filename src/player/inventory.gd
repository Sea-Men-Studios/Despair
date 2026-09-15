extends Node3D

@export var camera: Camera3D

var held_object: Node3D = null

func _process(_delta: float) -> void:
	if held_object:
		held_object.global_rotation = camera.global_rotation +  held_object.held_orientation
		
		held_object.global_position = camera.global_position + -camera.global_transform.basis.z

extends InteractableObject
@export var marker: Node3D
@export var player: CharacterBody3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func interact():
		player.position = marker.position
		collision_shape_3d.visible = false
		

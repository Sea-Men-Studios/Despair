extends InteractableObject
@export var marker: Node3D
@export var player: CharacterBody3D

func interact():
		player.position = marker.position
		#collision_shape_3d.visible = false
		

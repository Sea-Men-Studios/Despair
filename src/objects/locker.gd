extends InteractableObject
@export var marker: Node3D
@export var player: CharacterBody3D
@export var rotationAxis: Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact():
		animation_player.play_backwards("Take 001")
		await get_tree().create_timer(1.2).timeout
		player.position = marker.position
		#collision_shape_3d.visible = false
		player._in_locker()
		player.rotation = rotationAxis.rotation
		animation_player.play("Take 001")

		

extends InteractableObject
@export var marker: Node3D
@export var player: CharacterBody3D
@export var rotationAxis: Node3D
@onready var animation_player: AnimationPlayer = $Sketchfab_model/AnimationPlayer

func interact():
		animation_player.play_backwards("Take 001")
		await get_tree().create_timer(1.2).timeout
		player.position = marker.position
		player._in_locker()
		player.rotation.y = rotationAxis.rotation.y
		animation_player.play("Take 001")
		
		var heart_scene = load("res://scenes/ui/heart_minigame.tscn")
		var canvas_layer = heart_scene.instantiate()
		get_tree().root.add_child(canvas_layer)

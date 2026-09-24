extends Control

@export var player: CharacterBody3D
var player_camera: Camera3D

var freecam: PackedScene = preload("res://scenes/freecam.tscn")
var freecam_instance: Camera3D = null

func _ready() -> void:
	player_camera = player.find_child("Head").find_child("Camera3D")

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("debug_menu"):
			self.visible = !self.visible
		
		if event.is_action_pressed("freecam_toggle"):
			if freecam_instance:
				player.can_move = true
				player_camera.make_current()
				freecam_instance.queue_free()
			else:
				player.can_move = false
				var new_freecam: Camera3D = freecam.instantiate()
				get_tree().root.add_child(new_freecam)
				new_freecam.global_position = player_camera.global_position
				new_freecam.global_rotation = player_camera.global_rotation
				new_freecam.make_current()
				freecam_instance = new_freecam

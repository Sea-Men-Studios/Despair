class_name InteractableObject

extends Node3D

func interact():
	print("from main class")

func get_picked_up():
	self.queue_free()

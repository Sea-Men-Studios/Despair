class_name InteractableObject

extends Node3D

var target_inventory = null

var held_orientation = Vector3(0, 0, 0)

func interact():
	print("from main class")

func get_picked_up():
	target_inventory.held_object = self
	#self.queue_free()

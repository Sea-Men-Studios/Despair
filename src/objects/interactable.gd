class_name InteractableObject

extends Node3D

var item_type: Globals.ItemType

var target_inventory = null

var held_orientation = Vector3(0, 0, 0)

func interact():
	get_picked_up()

func get_picked_up():
	target_inventory.held_object = self
	#self.queue_free()

func set_item_type(type: Globals.ItemType):
	item_type = type

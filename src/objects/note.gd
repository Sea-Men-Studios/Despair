extends InteractableObject

#func _init():
	#held_orientation = Vector3(90, 0, 0)

func interact():
	get_picked_up()

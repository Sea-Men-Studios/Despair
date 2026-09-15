extends InteractableObject

func interact():
	print("touched " + self.name)
	get_picked_up()

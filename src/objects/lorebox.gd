extends InteractableObject


func interact():
		var lock_pick_scene = load("res://scenes/lock_pick.tscn")
		var canvas_layer = lock_pick_scene.instantiate()
		get_tree().root.add_child(canvas_layer)
		#print(canvas_layer.name)
		

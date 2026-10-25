extends InteractableObject

@export var model: CSGSphere3D

func interact():
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
	
	model.material = new_material

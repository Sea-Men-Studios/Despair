extends InteractableObject

var map_scene = preload("res://scenes/map.tscn")
# Called when the node enters the scene tree for the first time.
func interact():
	get_tree().change_scene_to_packed(map_scene)

extends InteractableObject

const MAP_SCENE: PackedScene = preload("res://scenes/map.tscn")

func interact() -> void:
	SceneLoader.change_scene_to_packed(MAP_SCENE)

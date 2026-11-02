extends InteractableObject

const MAP_SCENE: PackedScene = preload("res://scenes/map.tscn")


func _process(delta: float) -> void:
	if Globals.batteries_inserted == true:
		$".".visible = true

func interact() -> void:
	
	SceneLoader.change_scene_to_packed(MAP_SCENE)

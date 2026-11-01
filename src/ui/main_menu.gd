extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/SettingsPanel.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/prologue_level.tscn")


func _on_settings_pressed() -> void:
	$Control/SettingsPanel.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	$Control/SettingsPanel.visible = false


func _on_controls_pressed() -> void:
	$Control/ControlPanel.visible = true


func _on_back_2_pressed() -> void:
	$Control/ControlPanel.visible = false

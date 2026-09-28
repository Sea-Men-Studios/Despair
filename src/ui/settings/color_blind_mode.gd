extends CheckBox

func _on_toggled(_toggled_on: bool) -> void:
	Settings.color_blind_mode = button_pressed

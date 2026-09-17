extends ColorRect

func _ready() -> void:
	visible = Settings.color_blind_mode
	Settings.color_blind_mode_changed.connect(_on_toggled)

func _on_toggled(enabled: bool) -> void:
	visible = enabled

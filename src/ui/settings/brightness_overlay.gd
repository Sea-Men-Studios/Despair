extends ColorRect

func _ready() -> void:
	_apply_brightness(Settings.brightness)
	Settings.brightness_changed.connect(_apply_brightness)

func _apply_brightness(value: float) -> void:
	if value < 1.0:
		# Darken: black overlay, alpha increases as brightness drops
		color = Color(0, 0, 0, 1.0 - value)
	else:
		# Brighten: white overlay, alpha increases as brightness rises above 1
		var t = clamp(value - 1.0, 0.0, 1.0)
		color = Color(1, 1, 1, t * 0.5)  # cap so it doesn't fully whiteout

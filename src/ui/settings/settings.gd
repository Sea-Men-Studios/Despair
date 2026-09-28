extends Node

signal fov_changed(new_fov: float)
signal sensitivity_changed(new_sensitivity: float)
signal brightness_changed(new_brightness: float)
signal color_blind_mode_changed(enabled: bool)

var fov := 75.0:
	set(value):
		fov = clamp(value, 30.0, 150.0)
		fov_changed.emit(fov)

var sensitivity := 0.002:
	set(value):
		sensitivity = value
		sensitivity_changed.emit(sensitivity)

var brightness := 1.0:
	set(value):
		brightness = value
		brightness_changed.emit(brightness)
		
var color_blind_mode := false:
	set(value):
		color_blind_mode = value
		color_blind_mode_changed.emit(color_blind_mode)

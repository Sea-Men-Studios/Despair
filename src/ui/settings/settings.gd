extends Node

@export var audio_bus_name := "Master"

signal fov_changed(new_fov: float)
signal sensitivity_changed(new_sensitivity: float)
signal brightness_changed(new_brightness: float)
signal color_blind_mode_changed(enabled: bool)
signal volume_changed(new_volume: float)

var audio_bus_id := -1
var _volume := 75.0

var volume: float:
	get:
		return _volume
	set(value):
		_volume = clampf(value, 0.0, 100.0)
		_apply_volume()
		volume_changed.emit(_volume)

var fov := 75.0:
	set(value):
		fov = clampf(value, 30.0, 150.0)
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


func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)

	if audio_bus_id == -1:
		push_error("Settings: audio bus '%s' was not found." % audio_bus_name)
		return

	_apply_volume()


func _apply_volume() -> void:
	if audio_bus_id == -1:
		return

	# Convert the 0–100 slider value to a 0–1 linear value.
	# Use a low nonzero value at 0 to avoid passing -INF dB.
	var linear_volume := maxf(_volume / 100.0, 0.0001)
	AudioServer.set_bus_volume_db(audio_bus_id, linear_to_db(linear_volume))

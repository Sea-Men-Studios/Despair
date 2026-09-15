extends Node

signal fov_changed(new_fov: float)

var fov := 75.0:
	set(value):
		fov = value
		fov_changed.emit(fov)

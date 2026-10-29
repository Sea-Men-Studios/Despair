extends CanvasLayer

@export var min_load_time := 1.0
@export var max_load_time := 3.0

@onready var bg: ColorRect = $ColorRect
@onready var spinner: Control = $ColorRect/Spinner

var _busy := false

func _ready() -> void:
	bg.modulate.a = 0.0
	visible = false
	set_process(false)

func _process(delta: float) -> void:
	spinner.rotation += delta * 5.0

func change_scene(path: String) -> void:
	if _busy:
		return
	_busy = true
	visible = true
	set_process(true)

	# Fade in
	var tween := create_tween()
	tween.tween_property(bg, "modulate:a", 1.0, 0.25)
	await tween.finished

	# Start loading and fake timer at same time
	ResourceLoader.load_threaded_request(path)
	var delay_timer := get_tree().create_timer(randf_range(min_load_time, max_load_time))

	# Wait for the load to finish
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		push_error("Failed to load scene: " + path)
		await _fade_out()
		return

	# Wait out whatever is left of the minimum delay
	if delay_timer.time_left > 0.0:
		await delay_timer.timeout

	var packed := ResourceLoader.load_threaded_get(path) as PackedScene
	get_tree().change_scene_to_packed(packed)

	await _fade_out()

func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(bg, "modulate:a", 0.0, 0.25)
	await tween.finished
	visible = false
	set_process(false)
	_busy = false

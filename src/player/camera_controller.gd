extends Node3D

@onready var player: CharacterBody3D = $"../.."
const DEFAULT_HEIGHT : float = 0.336

@export_group("Mouse")
@export var mouse_sensitivity : float = 0.002
@export var tilt_limit : float = 89.0

@export_group("Step Smoothing")
@export var step_speed : float = 8.0

var mouse_input : Vector2 = Vector2.ZERO
var _target_height : float
var _step_smoothing : bool = false
var offset_height : float

func _ready() -> void:
	rotation = player.rotation
	offset_height = DEFAULT_HEIGHT
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_input += event.relative

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func update_camera_rotation(input: Vector2) -> void:
	player.rotate_y(-input.x * mouse_sensitivity)
	rotate_x(-input.y * mouse_sensitivity)
	rotation.x = clamp(rotation.x, deg_to_rad(-tilt_limit), deg_to_rad(tilt_limit))

func _process(delta: float) -> void:
	update_camera_rotation(mouse_input)
	mouse_input = Vector2.ZERO

	if _step_smoothing:
		_target_height = lerp(_target_height, 0.0, 1.0 - exp(-step_speed * delta))
		if abs(_target_height) < 0.01:
			_target_height = 0.0
			_step_smoothing = false

	position.y = offset_height + _target_height

func smooth_step(height_change : float) -> void:
	_target_height -= height_change
	_step_smoothing = true

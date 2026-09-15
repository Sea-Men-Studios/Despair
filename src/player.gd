extends CharacterBody3D

# Breathing bob
@export var breath_freq := 0.22
@export var breath_amp := 0.05
@export var breath_sway := 0.012
@export var exertion_freq_mult := 2.2
@export var exertion_amp_mult := 2.0
@export var exertion_smoothing := 2.0
var t_breath := 0.0
var exertion := 0.0

@export var min_pitch := -80.0
@export var max_pitch := 80.0 

@export var max_speed := 3.0
@export var acceleration := 3.0
@export var deceleration := 5
@export var air_control := 0.3


const SENSITIVITY = 0.002

@onready var camera: Camera3D = $Node3D/Camera3D
@onready var head: Node3D = $Node3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


	var input_dir := Input.get_vector("left", "right", "forwards", "backwards")
	var direction = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target_velocity = direction * max_speed

	var current_accel = acceleration if direction.length() > 0.1 else deceleration
	if not is_on_floor():
		current_accel *= air_control

	velocity.x = move_toward(velocity.x, target_velocity.x, current_accel * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, current_accel * delta)

	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	var target_exertion = clamp(horizontal_speed / max_speed, 0.0, 1.0)
	exertion = lerp(exertion, target_exertion, 1.0 - exp(-exertion_smoothing * delta))

	var freq = breath_freq * lerp(1.0, exertion_freq_mult, exertion)
	var amp = breath_amp * lerp(1.0, exertion_amp_mult, exertion)
	t_breath += delta * freq

	camera.transform.origin = _breathe(t_breath, amp)



	move_and_slide()



func _breathe(time: float, amp: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = (sin(time * TAU) * 0.7 + sin(time * TAU * 2.3 + 0.6) * 0.3) * amp
	pos.x = cos(time * TAU * 0.5) * breath_sway
	return pos

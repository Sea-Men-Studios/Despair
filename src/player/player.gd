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
@export var step_height := 0.5
@export var step_check_distance := 0.5

const SENSITIVITY = 0.002

@onready var camera: Camera3D = $Node3D/Camera3D
@onready var head: Node3D = $Node3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
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
	
	if is_on_floor():
		_try_step_up(delta)

	move_and_slide()

func _breathe(time: float, amp: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = (sin(time * TAU) * 0.7 + sin(time * TAU * 2.3 + 0.6) * 0.3) * amp
	pos.x = cos(time * TAU * 0.5) * breath_sway
	return pos

func _try_step_up(delta: float) -> void:
	var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
	if horizontal_vel.length() < 0.01:
		return
	var motion = horizontal_vel.normalized() * step_check_distance

	# 1. Is something blocking us at foot level right in front?
	var forward_collision := move_and_collide(motion, true)
	if forward_collision == null:
		return  # nothing in the way, no step needed

	# 2. Is there clear space if we lift up by step_height?
	var up_collision := move_and_collide(Vector3.UP * step_height, true)
	if up_collision != null:
		return  # something overhead, can't step up (it's a wall, not a step)

	# 3. With that headroom, is the path forward now clear?
	var forward_at_height := move_and_collide(motion, true)
	if forward_at_height != null:
		return  # still blocked even when raised, not a valid step

	# All clear: actually raise the body. move_and_slide() will then
	# carry it forward and gravity/floor snap will settle it onto the step.
	global_position.y += step_height

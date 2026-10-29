extends CharacterBody3D

@export_category("Breathing")
@export var breath_freq := 0.22
@export var breath_amp := 0.05
@export var breath_sway := 0.012
@export var exertion_freq_mult := 2.2
@export var exertion_amp_mult := 2.0
@export var exertion_smoothing := 2.0

@export_category("Look")
@export var min_pitch := -80.0
@export var max_pitch := 80.0

@export_category("Movement")
@export var max_speed := 4.5
@export var acceleration := 3.0
@export var deceleration := 5.0
@export_range(0.0, 1.0) var air_control := 0.3

@export_category("References")
@export var game: Node3D

@onready var camera: Camera3D = $Head/Camera3D
@onready var head: Node3D = $Head
@onready var overlays: CanvasLayer = $CanvasLayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var jumpscare_video: VideoStreamPlayer = $JumpscareLayer/VideoStreamPlayer

var jumpscare_playing := false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var has_gravity := true
var can_move := true

var t_breath := 0.0
var exertion := 0.0
var camera_rest_position := Vector3.ZERO


func _ready() -> void:
	overlays.visible = true
	camera_rest_position = camera.position
	camera.fov = Settings.fov

	if not Settings.fov_changed.is_connected(_on_fov_changed):
		Settings.fov_changed.connect(_on_fov_changed)

	if not jumpscare_video.finished.is_connected(_on_video_stream_player_finished):
		jumpscare_video.finished.connect(_on_video_stream_player_finished)

	jumpscare_video.autoplay = false
	jumpscare_video.visible = false


func _input(event: InputEvent) -> void:
	if not can_move:
		return

	if (
		event is InputEventMouseMotion
		and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	):
		rotate_y(-event.relative.x * Settings.sensitivity)
		camera.rotate_x(-event.relative.y * Settings.sensitivity)
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch)
		)


func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector3.ZERO
		return

	if has_gravity and not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir := Input.get_vector("left", "right", "forwards", "backwards")

	# Use the player's yaw for movement, not the camera's pitch.
	var direction := global_basis * Vector3(input_dir.x, 0.0, input_dir.y)
	direction.y = 0.0

	if direction.length_squared() > 0.0001:
		direction = direction.normalized()
	else:
		direction = Vector3.ZERO

	var target_velocity := direction * max_speed
	var current_acceleration := acceleration if direction != Vector3.ZERO else deceleration

	if not is_on_floor():
		current_acceleration *= air_control

	velocity.x = move_toward(
		velocity.x,
		target_velocity.x,
		current_acceleration * delta
	)
	velocity.z = move_toward(
		velocity.z,
		target_velocity.z,
		current_acceleration * delta
	)

	move_and_slide()
	_update_breathing(delta)


func _update_breathing(delta: float) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var target_exertion := clampf(horizontal_speed / max_speed, 0.0, 1.0)

	exertion = lerpf(
		exertion,
		target_exertion,
		1.0 - exp(-exertion_smoothing * delta)
	)

	var frequency := breath_freq * lerpf(1.0, exertion_freq_mult, exertion)
	var amplitude := breath_amp * lerpf(1.0, exertion_amp_mult, exertion)

	t_breath += delta * frequency

	camera.position = camera_rest_position + _breathe(t_breath, amplitude)


func _breathe(time: float, amplitude: float) -> Vector3:
	var offset := Vector3.ZERO
	offset.y = (
		sin(time * TAU) * 0.7
		+ sin(time * TAU * 2.3 + 0.6) * 0.3
	) * amplitude
	offset.x = cos(time * TAU * 0.5) * breath_sway
	return offset


func _in_locker() -> void:
	collision_shape.disabled = true
	has_gravity = false
	can_move = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("In Locker")


func _on_fov_changed(new_fov: float) -> void:
	camera.fov = new_fov

func play_jumpscare() -> void:
	if jumpscare_playing:
		return

	if jumpscare_video.stream == null:
		push_error("Jumpscare VideoStreamPlayer has no video stream assigned.")
		return

	jumpscare_playing = true
	can_move = false
	velocity = Vector3.ZERO

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	jumpscare_video.visible = true
	jumpscare_video.play()

	if not jumpscare_video.is_playing():
		push_error("Jumpscare video did not start. Check that its stream is valid.")
		jumpscare_playing = false
		can_move = true
		jumpscare_video.visible = false


func _on_video_stream_player_finished() -> void:
	get_tree().call_deferred(
		"change_scene_to_file",
		"res://scenes/ui/JumpScare.tscn"
	)

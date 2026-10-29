extends Node

@onready var player: CharacterBody3D = $".."

@export_category("References")
@export var collision_shape: CollisionShape3D

@export_category("Step Settings")
@export_range(0.0, 1.0) var surface_threshold: float = 0.6
@export var step_height: float = 0.7

const FEET_ADJUSTED_HEIGHT := 0.05
const MIN_STEP_HEIGHT := 0.2
const MIN_MOVEMENT_LENGTH := 0.1
const MIN_DOT_VALUE := 0.5
const WALL_PROBE_DEPTH := 0.05

var step_status := ""
var half_height := 0.0


func _ready() -> void:
	if collision_shape == null:
		for child in player.get_children():
			if child is CollisionShape3D:
				collision_shape = child
				break

	if collision_shape == null:
		push_error("StepHandler: no CollisionShape3D found.")
		return

	half_height = _get_shape_half_height(collision_shape.shape)

	if half_height <= 0.0:
		push_error("StepHandler: unsupported or invalid collision shape.")


func handle_step_climbing() -> void:
	if collision_shape == null or half_height <= 0.0:
		return

	var collision_count := player.get_slide_collision_count()
	if collision_count == 0:
		return

	step_status = "No step found."

	for i in range(collision_count):
		var collision := player.get_slide_collision(i)
		var normal := collision.get_normal()

		# A wall's normal is mostly horizontal. Avoid a raycast just to check this.
		if absf(normal.y) > surface_threshold:
			continue

		if not _is_valid_step_direction(normal):
			continue

		var measured_height := _measure_step_height(collision)
		if measured_height <= MIN_STEP_HEIGHT:
			continue
		if measured_height > step_height:
			continue
		if player.test_move(player.global_transform, Vector3.UP * measured_height):
			step_status = "No headroom."
			continue

		# Apply the adjustment once, then stop checking collisions.
		player.global_position.y += measured_height

		# Avoid restoring an old velocity unless you have confirmed it is needed:
		# player.velocity = player.previous_velocity

		if player.camera:
			player.camera.smooth_step(measured_height)

		step_status = "Step found: %.2f" % measured_height
		return


func _measure_step_height(collision: KinematicCollision3D) -> float:
	var wall_normal := collision.get_normal()
	wall_normal.y = 0.0

	if wall_normal.length_squared() < 0.001:
		return 0.0

	wall_normal = wall_normal.normalized()
	var probe := collision.get_position() - wall_normal * WALL_PROBE_DEPTH

	var feet_y := _get_player_feet_y()
	var head_y := collision_shape.global_position.y + half_height

	var query := PhysicsRayQueryParameters3D.create(
		Vector3(probe.x, head_y, probe.z),
		Vector3(probe.x, feet_y + FEET_ADJUSTED_HEIGHT, probe.z)
	)
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]

	var result := player.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return 0.0

	return result.position.y - feet_y


func _is_valid_step_direction(collision_normal: Vector3) -> bool:
	var input_dir: Vector2 = player.get_input_direction()
	var movement := player.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)

	if movement.length_squared() < MIN_MOVEMENT_LENGTH * MIN_MOVEMENT_LENGTH:
		return false

	return movement.normalized().dot(-collision_normal) > MIN_DOT_VALUE


func _get_player_feet_y() -> float:
	return collision_shape.global_position.y - half_height


func _get_shape_half_height(shape: Shape3D) -> float:
	if shape is CapsuleShape3D or shape is CylinderShape3D:
		return shape.height * 0.5
	if shape is BoxShape3D:
		return shape.size.y * 0.5
	if shape is SphereShape3D:
		return shape.radius

	return 0.0

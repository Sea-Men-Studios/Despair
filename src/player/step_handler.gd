extends Node
#
#
#
#
#
# TODO fix jittering
#
#
#
#
@onready var player: CharacterBody3D = $".."

@export_category("References")
@export var collision_shape : CollisionShape3D  # optional: auto-detected if left empty

@export_category("Step Settings")
@export var surface_threshold : float = 0.6
@export var step_height : float = 0.7

var step_status : String

const FEET_ADJUSTED_HEIGHT : float = 0.05
const MIN_STEP_HEIGHT : float = 0.1
const MIN_MOVEMENT_LENGTH : float = 0.1
const MIN_DOT_VALUE : float = 0.5
const WALL_PROBE_DEPTH : float = 0.05  # how far into the wall to probe for the step top
const RAY_OVERSHOOT : float = 0.1      # extend the wall-check ray past the contact point

func _ready() -> void:
	if collision_shape == null:
		for child in player.get_children():
			if child is CollisionShape3D:
				collision_shape = child
				break
	if collision_shape == null:
		push_error("StepHandler: no CollisionShape3D found. Assign one in the inspector.")

func handle_step_climbing() -> void:
	if collision_shape == null:
		return

	step_status = "No Vertical Collisions Detected."
	for i in player.get_slide_collision_count():
		var collision := player.get_slide_collision(i)
		if not _is_vertical_surface(collision):
			continue

		var measured_height := _measure_step_height(collision)
		if measured_height <= MIN_STEP_HEIGHT:
			step_status = "No Step Found: " + str(measured_height)
			continue
		if measured_height > step_height:
			step_status = "Step Too High: " + str(measured_height)
			continue
		if not _is_valid_step_direction(collision):
			step_status = "Invalid Step Direction"
			continue
		if player.test_move(player.global_transform, Vector3.UP * measured_height):
			step_status = "No Headroom For Step"
			continue

		player.global_position.y += measured_height
		player.velocity = player.previous_velocity # keep previous frame's velocity
		player.camera.smooth_step(measured_height) # enable camera smoothing
		step_status = "Step Found! Height: " + str(measured_height)
		break

func _is_vertical_surface(collision: KinematicCollision3D) -> bool:
	var normal := collision.get_normal()
	if abs(normal.y) <= surface_threshold:
		step_status = "CollisionShape: Vertical Collision Found! " + str(normal)
		return true
	return _check_collision_surface(collision)

func _check_collision_surface(collision: KinematicCollision3D) -> bool:
	var space_state := player.get_world_3d().direct_space_state

	var ray_start := _get_player_feet_position()
	var ray_end := collision.get_position()
	ray_end.y = ray_start.y

	var dir := ray_end - ray_start
	if dir.length() < 0.001:
		return false
	ray_end += dir.normalized() * RAY_OVERSHOOT

	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]

	var result := space_state.intersect_ray(query)
	if not result.is_empty() and abs(result.normal.y) <= surface_threshold:
		step_status = "Raycast: Vertical Collision Found! " + str(result.normal)
		return true
	step_status = "No Vertical Collision Detected."
	return false

func _get_half_height() -> float:
	var shape := collision_shape.shape
	if shape is CapsuleShape3D or shape is CylinderShape3D:
		return shape.height / 2.0
	if shape is BoxShape3D:
		return shape.size.y / 2.0
	if shape is SphereShape3D:
		return shape.radius
	push_warning("StepHandler: unsupported collision shape type.")
	return 0.0

func _get_player_feet_y() -> float:
	# Uses the shape node's position so an offset collision shape still works
	return collision_shape.global_position.y - _get_half_height()

func _get_player_feet_position() -> Vector3:
	var feet_pos := player.global_position
	feet_pos.y = _get_player_feet_y() + FEET_ADJUSTED_HEIGHT # small buffer
	return feet_pos

func _measure_step_height(collision: KinematicCollision3D) -> float:
	var space_state := player.get_world_3d().direct_space_state

	# Probe slightly INTO the wall so the downward ray lands on the step's top face
	var wall_normal := collision.get_normal()
	wall_normal.y = 0.0
	wall_normal = wall_normal.normalized()
	var probe := collision.get_position() - wall_normal * WALL_PROBE_DEPTH

	var feet_y := _get_player_feet_y()
	var head_y := collision_shape.global_position.y + _get_half_height()

	var ray_start := Vector3(probe.x, head_y, probe.z)
	var ray_end := Vector3(probe.x, feet_y + FEET_ADJUSTED_HEIGHT, probe.z)

	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]

	var result := space_state.intersect_ray(query)
	if not result.is_empty():
		return result.position.y - feet_y # measured from the true feet, not the buffered point

	return 0.0

func _is_valid_step_direction(collision: KinematicCollision3D) -> bool:
	var collision_normal := collision.get_normal()
	var input_dir: Vector2 = player.get_input_direction()
	var movement_direction: Vector3 = player.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	if movement_direction.length() > MIN_MOVEMENT_LENGTH:
		movement_direction = movement_direction.normalized()
		return movement_direction.dot(-collision_normal) > MIN_DOT_VALUE
	return false

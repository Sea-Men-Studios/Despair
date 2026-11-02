
extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $"Parasite L Starkie/AnimationPlayer"
@onready var jumpscare_area: Area3D = $JumpscareArea
@onready var stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var raycasts: Array[RayCast3D] = [
	$Raycasts/RayCast3D,
	$Raycasts/RayCast3D2,
	$Raycasts/RayCast3D3,
	$Raycasts/RayCast3D4,
	$Raycasts/RayCast3D5,
	$Raycasts/RayCast3D6,
	$Raycasts/RayCast3D7,
]

const ANIM_IDLE := "Anims/Idle"
const ANIM_WALK := "Anims/walk"
const ANIM_RUN := "Anims/run"

const JUMPSCARE_SOUND: AudioStream = preload(
	"res://assets/audio/monster/monster roar.mp3"
)

enum State { WANDER, CHASE }

@export_category("Movement")
@export var speed := 2.0
@export var chase_speed := 2.5

@export_category("Wandering")
@export var wander_radius := 15.0
@export var wander_wait_time := 2.0

@export_category("Detection")
@export var lose_sight_time := 3.0
@export var sight_check_interval := 0.1

@export_category("Performance")
@export var decision_interval := 0.1
@export var target_update_distance := 0.5

@export_category("Setup")
@export var spawn_point: Node3D
@export var gravity: float = ProjectSettings.get_setting(
	"physics/3d/default_gravity"
)

var state: State = State.WANDER
var player: Node3D
var current_anim := ""
var game: Node

var wander_timer := 0.0
var lose_sight_timer := 0.0
var decision_timer := 0.0
var sight_check_timer := 0.0

var last_player_target := Vector3.ZERO

var navigation_ready := false
var desired_velocity := Vector3.ZERO


func _ready() -> void:
	# Navigation avoidance.
	nav_agent.avoidance_enabled = true

	# Connect navigation signal.
	if not nav_agent.velocity_computed.is_connected(
		_on_navigation_agent_3d_velocity_computed
	):
		nav_agent.velocity_computed.connect(
			_on_navigation_agent_3d_velocity_computed
		)

	# Connect jumpscare.
	if not jumpscare_area.body_entered.is_connected(
		_on_jumpscare_area_body_entered
	):
		jumpscare_area.body_entered.connect(
			_on_jumpscare_area_body_entered
		)

	# Make animations loop.
	for anim_name in [ANIM_IDLE, ANIM_WALK, ANIM_RUN]:
		var anim := animation_player.get_animation(anim_name)

		if anim != null:
			anim.loop_mode = Animation.LOOP_LINEAR

	# Find player.
	player = get_tree().get_first_node_in_group("player") as Node3D

	if player == null:
		push_warning("Enemy: No player found in the 'player' group.")

	# Respawn at assigned spawn point.
	if spawn_point != null:
		respawn()

	# Wait for navigation map.
	call_deferred("_wait_for_navigation_map")


# --------------------------------------------------
# NAVIGATION INITIALIZATION
# --------------------------------------------------

func _wait_for_navigation_map() -> void:
	while is_inside_tree():
		var map_rid := nav_agent.get_navigation_map()

		if map_rid.is_valid():
			if NavigationServer3D.map_get_iteration_id(map_rid) > 0:
				var regions := NavigationServer3D.map_get_regions(map_rid)

				if regions.size() > 0:
					navigation_ready = true

					print("\n========== ENEMY NAVIGATION DEBUG ==========")
				print("Enemy: ", get_path())
				print("Enemy position: ", global_position)
				print("Navigation map RID: ", map_rid)

				var closest_point := NavigationServer3D.map_get_closest_point(
					map_rid,
					global_position
				)

				print("Closest navmesh point: ", closest_point)
				print(
					"Distance from navmesh: ",
					global_position.distance_to(closest_point)
				)

				print(
					"Navigation regions: ",
					NavigationServer3D.map_get_regions(map_rid).size()
				)

				print("============================================\n")

				navigation_ready = true

				_pick_new_wander_point()

				await get_tree().physics_frame

				print("Target position: ", nav_agent.target_position)
				print("Next path position: ", nav_agent.get_next_path_position())
				print("Navigation finished: ", nav_agent.is_navigation_finished())
				print("============================================")

				return

		await get_tree().physics_frame

	push_warning(
		"Enemy: Navigation map failed to initialize: " + str(get_path())
	)


# --------------------------------------------------
# PHYSICS AND MOVEMENT
# --------------------------------------------------

func _physics_process(delta: float) -> void:

	# Gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if not navigation_ready:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	# Player detection timer.
	sight_check_timer += delta

	if sight_check_timer >= sight_check_interval:
		var check_delta := sight_check_timer
		sight_check_timer = 0.0

		_check_raycasts(check_delta)

	# Decision timer.
	decision_timer += delta

	if decision_timer >= decision_interval:
		var decision_delta := decision_timer
		decision_timer = 0.0

		if state == State.CHASE:
			_process_chase()
		else:
			_process_wander(decision_delta)

	# Calculate desired movement.
	desired_velocity = Vector3.ZERO

	if not nav_agent.is_navigation_finished():

		var next_location := nav_agent.get_next_path_position()

		var direction := next_location - global_position
		direction.y = 0.0

		if direction.length_squared() > 0.0001:

			var move_speed := speed

			if state == State.CHASE:
				move_speed = chase_speed

			desired_velocity = direction.normalized() * move_speed

			# Rotate towards movement direction.
			var target_yaw := atan2(
				-desired_velocity.x,
				-desired_velocity.z
			)

			rotation.y = lerp_angle(
				rotation.y,
				target_yaw,
				10.0 * delta
			)

	# Send desired velocity to navigation avoidance.
	nav_agent.set_velocity(desired_velocity)

	# Movement is handled here only once.
	move_and_slide()

	_update_animation()


# Called when navigation avoidance calculates a safe velocity.
func _on_navigation_agent_3d_velocity_computed(
	safe_velocity: Vector3
) -> void:

	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z


# --------------------------------------------------
# PLAYER DETECTION
# --------------------------------------------------

func _check_raycasts(delta: float) -> void:

	var sees_player := false

	for ray in raycasts:

		if ray == null or not ray.is_enabled():
			continue

		ray.force_raycast_update()

		if not ray.is_colliding():
			continue

		var collider := ray.get_collider() as Node

		if _is_player_collider(collider):
			sees_player = true
			break

	if sees_player:

		lose_sight_timer = 0.0

		if state != State.CHASE:

			state = State.CHASE

			if is_instance_valid(player):
				last_player_target = player.global_position
				update_target_location(last_player_target)

			print("Spotted player - chasing: ", name)

			_set_music_song(4)

	elif state == State.CHASE:

		lose_sight_timer += delta

		if lose_sight_timer >= lose_sight_time:

			state = State.WANDER
			lose_sight_timer = 0.0

			print("Lost player - back to wandering: ", name)

			_pick_new_wander_point()
			_set_music_song(1)


func _is_player_collider(collider: Node) -> bool:

	var current := collider

	while current != null:

		if current.is_in_group("player"):
			return true

		current = current.get_parent()

	return false


# --------------------------------------------------
# WANDERING
# --------------------------------------------------

func _process_wander(delta: float) -> void:

	if nav_agent.is_navigation_finished():

		wander_timer += delta

		if wander_timer >= wander_wait_time:
			_pick_new_wander_point()

	else:
		wander_timer = 0.0


func _pick_new_wander_point() -> void:

	if not navigation_ready:
		return

	var map_rid := nav_agent.get_navigation_map()

	if not map_rid.is_valid():
		return

	# Find a random reachable point on the navigation mesh.
	for i in range(8):

		var random_offset := Vector3(
			randf_range(-wander_radius, wander_radius),
			0.0,
			randf_range(-wander_radius, wander_radius)
		)

		var candidate := global_position + random_offset

		var nav_point := NavigationServer3D.map_get_closest_point(
			map_rid,
			candidate
		)

		if nav_point.distance_to(global_position) <= wander_radius * 1.5:

			update_target_location(nav_point)

			wander_timer = 0.0
			return

	# Fallback.
	update_target_location(global_position)


# --------------------------------------------------
# CHASING
# --------------------------------------------------

func _process_chase() -> void:

	if not is_instance_valid(player):

		player = get_tree().get_first_node_in_group("player") as Node3D

		if player == null:
			return

	var target := player.global_position

	var threshold_squared := (
		target_update_distance * target_update_distance
	)

	if target.distance_squared_to(last_player_target) >= threshold_squared:

		update_target_location(target)

		last_player_target = target


func update_target_location(target_location: Vector3) -> void:

	if not navigation_ready:
		return

	nav_agent.set_target_position(target_location)


# --------------------------------------------------
# ANIMATIONS
# --------------------------------------------------

func _update_animation() -> void:

	var target_anim := ANIM_IDLE

	var horizontal_speed := Vector2(
		velocity.x,
		velocity.z
	).length()

	if horizontal_speed > 0.1:

		if state == State.CHASE:
			target_anim = ANIM_RUN
		else:
			target_anim = ANIM_WALK

	if target_anim != current_anim:

		current_anim = target_anim

		animation_player.play(current_anim, 0.3)


func _on_navigation_agent_3d_target_reached() -> void:
	print("In Range")


# --------------------------------------------------
# JUMPSCARE
# --------------------------------------------------

func _on_jumpscare_area_body_entered(body: Node3D) -> void:

	if body.is_in_group("player") and body.has_method("play_jumpscare"):

		stream_player.stream = JUMPSCARE_SOUND
		stream_player.play()

		body.play_jumpscare()


# --------------------------------------------------
# MUSIC
# ORIGINAL MUSIC LOGIC PRESERVED
# --------------------------------------------------

func _set_music_song(song_id: int) -> void:

	if game == null or not is_instance_valid(game):
		return

	if not game.has_method("get"):
		return

	var music_player = game.get("music_player")

	if music_player != null and music_player.has_method("set_song"):
		music_player.set_song(song_id)


# --------------------------------------------------
# RESPAWNING
# --------------------------------------------------

func respawn() -> void:

	if spawn_point == null:
		return

	global_transform = spawn_point.global_transform

	velocity = Vector3.ZERO

	lose_sight_timer = 0.0
	wander_timer = 0.0

	state = State.WANDER

	show()
	set_physics_process(true)

	if navigation_ready:
		_pick_new_wander_point()

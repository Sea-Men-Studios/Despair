extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
var SPEED = 2.0
var CHASE_SPEED = 2.5

var frame_counter := 0
@export var run_every_n_frames := 5

@onready var animation_player: AnimationPlayer = $"Parasite L Starkie/AnimationPlayer"
const ANIM_IDLE = "Anims/Idle"
const ANIM_WALK = "Anims/walk"
const ANIM_RUN = "Anims/run"

var current_anim := ""

@onready var raycasts: Array[RayCast3D] = [
	$Raycasts/RayCast3D,
	$Raycasts/RayCast3D2,
	$Raycasts/RayCast3D3,
	$Raycasts/RayCast3D4,
	$Raycasts/RayCast3D5,
	$Raycasts/RayCast3D6,
	$Raycasts/RayCast3D7,
]

enum State { WANDER, CHASE }
var state := State.WANDER

var player: Node3D = null

@export var wander_radius := 15.0
@export var wander_wait_time := 2.0  # pause between picking new wander points
var wander_timer := 0.0

@export var lose_sight_time := 3.0  # seconds without seeing player before giving up chase
var lose_sight_timer := 0.0

func _ready() -> void:
	for anim_name in [ANIM_IDLE, ANIM_WALK, ANIM_RUN]:
		animation_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
	player = get_tree().get_first_node_in_group("player")
	print("Player found: ", player)
	_pick_new_wander_point()

func _update_animation() -> void:
	var target_anim := ANIM_IDLE

	# Moving = has horizontal velocity (not just a path target)
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if horizontal_speed > 0.1:
		target_anim = ANIM_RUN if state == State.CHASE else ANIM_WALK

	if target_anim != current_anim:
		current_anim = target_anim
		animation_player.play(current_anim, 0.3)  # 0.3s blend between animations

func _physics_process(delta: float) -> void:
	frame_counter += 1
	if frame_counter < run_every_n_frames:
		return
	frame_counter = 0
	_check_raycasts()
	#print("State: ", state, " | Sees via raycast this frame: ", state == State.CHASE)

	match state:
		State.WANDER:
			_process_wander(delta)
		State.CHASE:
			_process_chase(delta)

	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var speed = CHASE_SPEED if state == State.CHASE else SPEED
	var new_velocity = (next_location - current_location).normalized() * speed
	
	if new_velocity.length() > 0.1:
		var target_yaw = atan2(-new_velocity.x, -new_velocity.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 10.0 * delta)

	nav_agent.set_velocity(new_velocity)
	
func _check_raycasts() -> void:
	var sees_player := false
	for ray in raycasts:
		if ray.is_colliding():
			#print(ray.name, " colliding with: ", ray.get_collider())
			var collider = ray.get_collider()
			if collider == player or collider.is_in_group("player"):
				sees_player = true
				break

	if sees_player:
		lose_sight_timer = 0.0
		if state != State.CHASE:
			state = State.CHASE
			print("Spotted player - chasing")
	elif state == State.CHASE:
		lose_sight_timer += get_physics_process_delta_time()
		if lose_sight_timer >= lose_sight_time:
			state = State.WANDER
			print("Lost player - back to wandering")
			_pick_new_wander_point()

func _process_wander(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		wander_timer += delta
		if wander_timer >= wander_wait_time:
			_pick_new_wander_point()
	else:
		wander_timer = 0.0

func _process_chase(_delta: float) -> void:
	if player:
		update_target_location(player.global_transform.origin)

func _pick_new_wander_point() -> void:
	var random_offset = Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)
	var target = global_transform.origin + random_offset
	update_target_location(target)
	wander_timer = 0.0

func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func _on_navigation_agent_3d_target_reached() -> void:
	print("In Range")

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()
	_update_animation()

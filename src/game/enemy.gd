extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $"Parasite L Starkie/AnimationPlayer"
@onready var jumpscare_area: Area3D = $JumpscareArea

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

var state := State.WANDER
var player: Node3D
var current_anim := ""

var wander_timer := 0.0
var lose_sight_timer := 0.0
var decision_timer := 0.0
var sight_check_timer := 0.0
var last_player_target := Vector3.ZERO


func _ready() -> void:
	jumpscare_area.body_entered.connect(_on_jumpscare_area_body_entered)
	for anim_name in [ANIM_IDLE, ANIM_WALK, ANIM_RUN]:
		var anim := animation_player.get_animation(anim_name)
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

	player = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		push_warning("Enemy: no Node3D found in the 'player' group.")

	_pick_new_wander_point()


func _physics_process(delta: float) -> void:
	decision_timer += delta
	sight_check_timer += delta

	if sight_check_timer >= sight_check_interval:
		var elapsed := sight_check_timer
		sight_check_timer = 0.0
		_check_raycasts(elapsed)

	if decision_timer >= decision_interval:
		var elapsed := decision_timer
		decision_timer = 0.0

		match state:
			State.WANDER:
				_process_wander(elapsed)
			State.CHASE:
				_process_chase()

	# Update steering every physics frame for smooth movement.
	var next_location := nav_agent.get_next_path_position()
	var direction := next_location - global_position
	direction.y = 0.0

	var move_speed := chase_speed if state == State.CHASE else speed
	var new_velocity := Vector3.ZERO

	if direction.length_squared() > 0.0001:
		new_velocity = direction.normalized() * move_speed

	if new_velocity.length_squared() > 0.01:
		var target_yaw := atan2(-new_velocity.x, -new_velocity.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 10.0 * delta)

	nav_agent.set_velocity(new_velocity)


func _check_raycasts(delta: float) -> void:
	var sees_player := false

	for ray in raycasts:
		if not ray.is_colliding():
			continue

		var collider := ray.get_collider()
		if collider == player or (
			collider is Node and collider.is_in_group("player")
		):
			sees_player = true
			break

	if sees_player:
		lose_sight_timer = 0.0

		if state != State.CHASE:
			state = State.CHASE
			if is_instance_valid(player):
				update_target_location(player.global_position)
				last_player_target = player.global_position
			print("Spotted player - chasing")

	elif state == State.CHASE:
		lose_sight_timer += delta

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


func _process_chase() -> void:
	if not is_instance_valid(player):
		return

	var target := player.global_position
	var threshold_squared := target_update_distance * target_update_distance

	if target.distance_squared_to(last_player_target) >= threshold_squared:
		update_target_location(target)
		last_player_target = target


func _pick_new_wander_point() -> void:
	var random_offset := Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)

	update_target_location(global_position + random_offset)
	wander_timer = 0.0


func update_target_location(target_location: Vector3) -> void:
	nav_agent.set_target_position(target_location)


func _update_animation() -> void:
	var target_anim := ANIM_IDLE
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()

	if horizontal_speed > 0.1:
		target_anim = ANIM_RUN if state == State.CHASE else ANIM_WALK

	if target_anim != current_anim:
		current_anim = target_anim
		animation_player.play(current_anim, 0.3)


func _on_navigation_agent_3d_target_reached() -> void:
	print("In Range")


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()
	_update_animation()


func _on_jumpscare_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.has_method("play_jumpscare"):
		body.play_jumpscare()

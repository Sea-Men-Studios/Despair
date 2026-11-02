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
var movement_speed_this_frame := 0.0


func _ready() -> void:
	nav_agent.avoidance_enabled = true

	if spawn_point != null:
		respawn()

	if not nav_agent.velocity_computed.is_connected(
		_on_navigation_agent_3d_velocity_computed
	):
		nav_agent.velocity_computed.connect(
			_on_navigation_agent_3d_velocity_computed
		)

	if not jumpscare_area.body_entered.is_connected(
		_on_jumpscare_area_body_entered
	):
		jumpscare_area.body_entered.connect(
			_on_jumpscare_area_body_entered
		)

	for anim_name in [ANIM_IDLE, ANIM_WALK, ANIM_RUN]:
		var anim := animation_player.get_animation(anim_name)
		if anim != null:
			anim.loop_mode = Animation.LOOP_LINEAR

	player = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		push_warning("Enemy: no Node3D found in the 'player' group.")

	# Wait for the navigation map to synchronize before choosing a target.
	call_deferred("_wait_for_navigation_map")
	call_deferred("_pick_new_wander_point")


func _wait_for_navigation_map() -> void:
	while is_inside_tree():
		var map_rid := nav_agent.get_navigation_map()
		if map_rid.is_valid() \
		and NavigationServer3D.map_get_iteration_id(map_rid) > 0:
			navigation_ready = true
			print("Navigation map ready; choosing wander target")
			
			print("Enemy ready: ", get_path(), " id=", get_instance_id())
			_pick_new_wander_point()
			return

		await get_tree().physics_frame



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var map_rid := nav_agent.get_navigation_map()
	if not map_rid.is_valid():
		return

	if NavigationServer3D.map_get_iteration_id(map_rid) == 0:
		return

	# Query every physics frame so the path stays current.
	var next_location := nav_agent.get_next_path_position()
	var direction := next_location - global_position
	direction.y = 0.0

	var desired_velocity := Vector3.ZERO

	if not nav_agent.is_navigation_finished() \
	and direction.length_squared() > 0.0001:
		var move_speed := chase_speed if state == State.CHASE else speed
		desired_velocity = direction.normalized() * move_speed

		var target_yaw := atan2(-desired_velocity.x, -desired_velocity.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 10.0 * delta)

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	move_and_slide()
	_update_animation()


func _on_navigation_agent_3d_velocity_computed(
	
	safe_velocity: Vector3
) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z
	print("velocity callback: ", safe_velocity)
	move_and_slide()
	_update_animation()

func _check_raycasts(delta: float) -> void:
	var sees_player := false

	for ray in raycasts:
		if ray == null or not ray.is_enabled() or not ray.is_colliding():
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
			_set_music_song(4)

	elif state == State.CHASE:
		lose_sight_timer += delta

		if lose_sight_timer >= lose_sight_time:
			state = State.WANDER
			lose_sight_timer = 0.0
			print("Lost player - back to wandering")
			_pick_new_wander_point()
			_set_music_song(1)


func _process_wander(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		wander_timer += delta

		if wander_timer >= wander_wait_time:
			_pick_new_wander_point()
	else:
		wander_timer = 0.0


func _process_chase() -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
		if player == null:
			return

	var target := player.global_position
	var threshold_squared := target_update_distance * target_update_distance

	if target.distance_squared_to(last_player_target) >= threshold_squared:
		update_target_location(target)
		last_player_target = target


func _pick_new_wander_point() -> void:
	if not navigation_ready:
		return

	var random_offset := Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)

	update_target_location(global_position + random_offset)
	wander_timer = 0.0


func update_target_location(target_location: Vector3) -> void:
	if navigation_ready:
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


func _on_jumpscare_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.has_method("play_jumpscare"):
		stream_player.stream = JUMPSCARE_SOUND
		stream_player.play()
		body.play_jumpscare()


func _set_music_song(song_id: int) -> void:
	if game == null or not is_instance_valid(game):
		return

	if not game.has_method("get"):
		return

	var music_player = game.get("music_player")
	if music_player != null and music_player.has_method("set_song"):
		music_player.set_song(song_id)


func respawn() -> void:
	if spawn_point == null:
		return

	global_transform = spawn_point.global_transform
	show()
	set_physics_process(true)

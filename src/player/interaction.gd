extends Node3D

@export var camera: Camera3D
@export var crosshair: PanelContainer
@export var inventory: Node3D
@export var player_hitbox: CollisionShape3D

var init_crosshair_size: Vector2

const RAY_LENGTH = 5 # Reach distance
var space_state: PhysicsDirectSpaceState3D
var hovered_obj: InteractableObject = null

func _ready():
	init_crosshair_size = crosshair.get_size()

func _physics_process(_delta: float) -> void:
	space_state = get_world_3d().direct_space_state
	check_hovered()

func interact():
	hovered_obj.target_inventory = inventory
	hovered_obj.interact()

func check_hovered():
	var viewport_center = Vector2(1920, 1080) / 2
	
	var origin = camera.project_ray_origin(viewport_center)
	var end = origin + camera.project_ray_normal(viewport_center) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	if player_hitbox: query.exclude = [player_hitbox]
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var obj_node = result["collider"].get_parent()
		if obj_node is InteractableObject:
			crosshair.set_size(init_crosshair_size * 2)
			hovered_obj = obj_node
		else:
			crosshair.set_size(init_crosshair_size)
			hovered_obj = null

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("interact"):
			interact()

extends Node3D

@export var camera: Camera3D
@export var player_hitbox: CollisionShape3D

const RAY_LENGTH = 1000
var space_state: PhysicsDirectSpaceState3D

func _physics_process(_delta: float) -> void:
	space_state = get_world_3d().direct_space_state

func interact():
	var viewport_center = get_viewport().size / 2
	print(viewport_center)
	
	var origin = camera.project_ray_origin(viewport_center)
	var end = origin + camera.project_ray_normal(viewport_center) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	if player_hitbox: query.exclude = [player_hitbox]
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)#["collider"]
	print(result)
	#print(result.get_parent().name)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("interact"):
			interact()

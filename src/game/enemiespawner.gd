extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_distance := 60.0
@export var despawn_distance := 80.0

var player: Node3D

var spawn_points: Array[Node3D] = []
var active_enemies: Dictionary = {}


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	for child in get_children():
		if child is Node3D:
			spawn_points.append(child)


func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	for point in spawn_points:
		var distance = player.global_position.distance_to(
			point.global_position
		)

		if not active_enemies.has(point):
			if distance <= spawn_distance:
				spawn_enemy(point)

		else:
			var enemy = active_enemies[point]

			if distance >= despawn_distance:
				enemy.queue_free()
				active_enemies.erase(point)


func spawn_enemy(point: Node3D) -> void:
	var enemy = enemy_scene.instantiate()

	get_tree().current_scene.add_child(enemy)

	enemy.global_transform = point.global_transform

	active_enemies[point] = enemy

extends Area3D

@export var group_id: int

var toggled: bool = false
var game: Node3D

func _ready():
	game = get_tree().current_scene
	body_entered.connect(_on_body_entered)

func _on_body_entered(area) -> void: 
	if area.name == "Player" and toggled == false:
		toggled = true
		game.receive_group_message(group_id)

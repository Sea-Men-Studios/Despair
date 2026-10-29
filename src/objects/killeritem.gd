extends InteractableObject

@export var item_id: int

var game
var player

func _ready():
	game = get_tree().current_scene
	player = game.find_child("Player")
	
	held_orientation = Vector3(0, -30.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.IMPORTANT_ITEM)

func use():
	player.kill()

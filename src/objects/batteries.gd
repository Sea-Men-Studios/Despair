extends InteractableObject

@export var item_id: int

var game
var player
#var inventory

func _ready():
	game = get_tree().current_scene
	player = game.find_child("Player")
	#inventory = player.inventory
	
	held_offset = Vector3(0.2, -0.1, -0.35)
	held_orientation = Vector3(0, -30.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.IMPORTANT_ITEM)

func interact():
	get_picked_up()
	game.objective_controller.complete_objective("1")
	game.objective_controller.add_objective("2")

func use():
	if player.inventory.key_items_aquired["2"] == true:
		player.inventory.put_away()
		player.inventory.key_items_aquired[str(item_id)] = false
		Globals.batteries_inserted = true
		game.receive_message()
		game.objective_controller.complete_objective("2")

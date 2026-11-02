extends InteractableObject

@export var note_id: int
var game: Node3D

func _ready():
	game = get_tree().current_scene
	held_orientation = Vector3(PI, -15.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.MISC_NOTE_ITEM)

func interact():
	get_picked_up()
	game.receive_message("I don’t even know who those people are. They’re not important. Over.")

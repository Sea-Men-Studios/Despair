extends InteractableObject

@export var note_id: int
@export var game: Node3D

func _ready():
	held_orientation = Vector3(PI, -15.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.NOTE_ITEM)

func interact():
	get_picked_up()
	game.receive_message("Look at that view. My chalet’s along that lake. Over.")

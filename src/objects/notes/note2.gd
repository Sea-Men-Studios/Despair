extends InteractableObject

@export var note_id: int
@export var game: Node3D

func _ready():
	game = get_tree().current_scene
	held_orientation = Vector3(PI, -15.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.NOTE_ITEM)

func interact():
	get_picked_up()
	game.receive_message(" Oh boo-hoo, what a sob story. He broke the NDA, he got what he deserved. Continue on. Over.")

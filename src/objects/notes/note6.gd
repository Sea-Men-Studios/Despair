extends InteractableObject

@export var note_id: int
@export var game: Node3D

func _ready():
	game = get_tree().current_scene
	held_orientation = Vector3(PI, -15.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.NOTE_ITEM)

func interact():
	get_picked_up()
	game.receive_message("… Where the hell did you get that? Put it down. Right now.
")
	game.receive_message("I've been very patient with you. I gave you one simple job, ONE. and instead you decide to go digging through confidential company property! ")
	game.receive_message("Get back to work. Over.")

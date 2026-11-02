extends InteractableObject

@export var note_id: int
@export var game: Node3D

func _ready():
	game = get_tree().current_scene
	held_orientation = Vector3(PI, -15.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.NOTE_ITEM)

func interact():
	get_picked_up()
	game.receive_message("THAT'S IT! I'VE HAD ENOUGH OF YOU! I GAVE YOU ONE SIMPLE JOB, AND YOU'VE DONE NOTHING BUT SNOOP AROUND IN COMPANY BUSINESS!
")
	game.receive_message("Orison Bio Solutions had nothing to do with this disaster! NOTHING! DO YOU UNDERSTAND?!
")
	game.receive_message("I'm not getting paid enough for this. Over.")

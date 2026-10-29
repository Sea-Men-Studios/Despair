extends InteractableObject

@export var note_id: int

func _ready():
	held_orientation = Vector3(PI, -15.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.NOTE_ITEM)

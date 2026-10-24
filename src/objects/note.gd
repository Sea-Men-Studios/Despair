extends InteractableObject

@export var note_number: int

func _ready():
	set_item_type(Globals.ItemType.NOTE_ITEM)

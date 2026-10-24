extends InteractableObject

@export var note_id: int

func _ready():
	set_item_type(Globals.ItemType.NOTE_ITEM)

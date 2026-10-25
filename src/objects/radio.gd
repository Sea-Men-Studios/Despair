extends InteractableObject

@export var item_id: int

func _ready():
	held_orientation = Vector3(80, 0, 100)
	set_item_type(Globals.ItemType.IMPORTANT_ITEM)

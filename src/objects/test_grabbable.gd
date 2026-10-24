extends InteractableObject

@export var item_id: int

func _ready():
	set_item_type(Globals.ItemType.IMPORTANT_ITEM)

extends InteractableObject

@export var item_id: int

var game

func _ready():
	game = get_tree().root
	
	held_orientation = Vector3(0, -30.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.IMPORTANT_ITEM)

func use():
	scale *= Vector3(1.2, 1.2, 1.2)

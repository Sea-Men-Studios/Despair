extends InteractableObject

@export var item_id: int

func _ready():
	held_orientation = Vector3(0, -10.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.IMPORTANT_ITEM)

#func _process(delta):
	#held_orientation += Vector3(0, 1*delta, 0)
	#print(held_orientation)

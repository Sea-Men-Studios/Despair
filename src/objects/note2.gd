extends InteractableObject

@export var objectives_controller: Control
@export var note_id: int

func _ready():
	set_item_type(Globals.ItemType.NOTE_ITEM)

func get_picked_up():
	if target_inventory.held_object:
		target_inventory.put_away()
	
	objectives_controller.complete_objective("1")
	target_inventory.held_object = self

extends InventoryPanel

@onready var note_ui_element: PackedScene = preload("res://scenes/ui/inventory_note.tscn")

@export var note_container: Container

func load_content(inventory: Control):
	var player_inventory = inventory.player.find_child("Inventory")
	
	for child in note_container.get_children():
		child.queue_free()
		
	for note_index in player_inventory.notes_aquired:
		var new_note_element = note_ui_element.instantiate()
		var new_note_element_button: Button = new_note_element.find_child("Button")
		
		new_note_element_button.text = "Note #" + str(note_index)
		
		note_container.add_child(new_note_element)
	

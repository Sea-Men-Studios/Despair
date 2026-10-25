extends InventoryPanel

@onready var item_element: PackedScene = preload("res://scenes/ui/inventory_item.tscn")
@onready var note_item: PackedScene = preload("res://scenes/items/note.tscn")
@onready var game: Node3D = get_tree().get_current_scene()

@export var note_container: Container

func load_content(inventory: Control):
	var player_inventory = inventory.player.find_child("Inventory")
	
	for child in note_container.get_children():
		child.queue_free()
		
	for note_id in player_inventory.notes_aquired.keys():
		if player_inventory.notes_aquired[note_id] == true:
			var new_item_element = item_element.instantiate()
			var new_item_element_button: Button = new_item_element.find_child("Button")
			
			new_item_element_button.pressed.connect(_load_note.bind(int(note_id), player_inventory))
			new_item_element_button.text = "Note No." + note_id
			
			note_container.add_child(new_item_element)

func _load_note(id: int, inventory: Node3D):
	if inventory.held_object:
		inventory.put_away()
	
	var new_note_item = Globals.notes[str(id)]["scene"].instantiate()
	
	game.find_child("World").add_child(new_note_item)
	inventory.held_object = new_note_item
	inventory.held_from_inventory = true

extends InventoryPanel

@onready var note_ui_element: PackedScene = preload("res://scenes/ui/inventory_note.tscn")
@onready var note_item: PackedScene = preload("res://scenes/items/note.tscn")
@onready var game: Node3D = get_tree().get_current_scene()

@export var note_container: Container

func load_content(inventory: Control):
	var player_inventory = inventory.player.find_child("Inventory")
	
	for child in note_container.get_children():
		child.queue_free()
		
	for note_index in player_inventory.notes_aquired:
		var new_note_element = note_ui_element.instantiate()
		var new_note_element_button: Button = new_note_element.find_child("Button")
		
		new_note_element_button.text = "Note #" + str(note_index)
		new_note_element_button.pressed.connect(_load_note.bind(note_index, player_inventory))
		
		note_container.add_child(new_note_element)

func _load_note(index: int, inventory: Node3D):
	if inventory.held_object:
		inventory.put_away()
	
	var new_note_item = inventory.note_scenes[str(index)].instantiate()
	
	game.find_child("World").add_child(new_note_item)
	inventory.held_object = new_note_item
	inventory.held_from_inventory = true

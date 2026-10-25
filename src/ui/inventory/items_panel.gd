extends InventoryPanel

@onready var item_element: PackedScene = preload("res://scenes/ui/inventory_item.tscn")
@onready var game: Node3D = get_tree().get_current_scene()

@export var item_container: Container

func load_content(inventory: Control):
	var player_inventory = inventory.player.find_child("Inventory")
	
	for child in item_container.get_children():
		child.queue_free()
		
	for key_item_id in player_inventory.key_items_aquired.keys():
		if player_inventory.key_items_aquired[key_item_id] == true:
			var new_item_element = item_element.instantiate()
			var new_item_element_button: Button = new_item_element.find_child("Button")
			
			new_item_element_button.pressed.connect(_load_item.bind(int(key_item_id), player_inventory))
			new_item_element_button.text = Globals.key_items[key_item_id]["name"]
			
			item_container.add_child(new_item_element)

func _load_item(id: int, inventory: Node3D):
	if inventory.held_object:
		inventory.put_away()
	
	var new_item = Globals.key_items[str(id)]["scene"].instantiate()
	
	game.find_child("World").add_child(new_item)
	inventory.held_object = new_item
	inventory.held_from_inventory = true

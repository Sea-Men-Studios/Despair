extends Node3D

@export var camera: Camera3D

var held_object: Node3D = null
var held_from_inventory: bool = false

var notes_aquired: Dictionary = {}
var key_items_aquired: Dictionary = {}

func _ready() -> void:
	for note_id in Globals.notes.keys():
		notes_aquired[str(note_id)] = false
	
	for key_item_id in Globals.key_items.keys():
		key_items_aquired[str(key_item_id)] = false

func _input(event: InputEvent) -> void:
	if held_object != null:
		if event is InputEventKey and event.is_action_pressed("put_away"):
			put_away()
		if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_RIGHT and event.is_pressed() == true:
			held_object.use()

func put_away():
	if held_object.item_type == Globals.ItemType.NOTE_ITEM:
		if held_from_inventory == false: notes_aquired[str(held_object.note_id)] = true
		held_object.queue_free()
		held_from_inventory = false
	elif held_object.item_type == Globals.ItemType.IMPORTANT_ITEM:
		if held_from_inventory == false: key_items_aquired[str(held_object.item_id)] = true
		held_object.queue_free()
		held_from_inventory = false

func _process(_delta: float) -> void:
	if held_object:
		var camera_quat = Quaternion(camera.global_transform.basis)
		var held_quat = Quaternion.from_euler(held_object.held_orientation)
		held_object.global_rotation = (camera_quat * held_quat).get_euler()
		
		held_object.global_position = camera.global_position + camera.global_transform.basis * held_object.held_offset

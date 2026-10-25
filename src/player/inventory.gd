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
		notes_aquired[str(key_item_id)] = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("put_away") and held_object != null:
		put_away()

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
		held_object.global_rotation = camera.global_rotation +  held_object.held_orientation
		held_object.global_position = camera.global_position + -camera.global_transform.basis.z + camera.global_transform.basis.x*0.8

extends Node3D

@export var camera: Camera3D

var held_object: Node3D = null
var held_from_inventory: bool = false

var notes_aquired: Array[int] = []
var note_scenes: Dictionary[String, PackedScene] = {
	"1": load("res://scenes/items/note.tscn"),
	"2": load("res://scenes/items/note2.tscn"),
}

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("put_away") and held_object != null:
		put_away()

func put_away():
	if held_from_inventory == false:
		if held_object.item_type == Globals.ItemType.NOTE_ITEM:
			notes_aquired.append(held_object.note_number)
			held_object.queue_free()
			held_from_inventory = false
	else:
		if held_object.item_type == Globals.ItemType.NOTE_ITEM:
			held_object.queue_free()
			held_from_inventory = false

func _process(_delta: float) -> void:
	if held_object:
		held_object.global_rotation = camera.global_rotation +  held_object.held_orientation
		held_object.global_position = camera.global_position + -camera.global_transform.basis.z + camera.global_transform.basis.x*0.8

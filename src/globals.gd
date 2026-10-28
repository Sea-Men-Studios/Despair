extends Node

enum ItemType {NULL, NOTE_ITEM, IMPORTANT_ITEM}

var song_folder: String = "res://assets/audio/music/"
var songs: Array[AudioStreamMP3] = [
	load(song_folder + "Despair.mp3"),
	load(song_folder + "Act1_Entrapped.mp3"),
	load(song_folder + "Prologue_Itchy_Neck.mp3")
]

var notes: Dictionary = {
	"1": {"scene": load("res://scenes/items/note.tscn")},
	"2": {"scene": load("res://scenes/items/note2.tscn")}
}

var key_items: Dictionary = {
	"1": {"scene": load("res://scenes/items/key_item.tscn"), "name": "Test Key Item"},
	"2": {"scene": load("res://scenes/items/radio.tscn"), "name": "Radio"},
}

var objectives: Dictionary = {
	"1": "Pick up Test Key Item"
}

var dialogue_lines: Dictionary = {
	"1": "Dialogue 1",
	"2": "Dialogue 2",
	"3": "Dialogue 3",
	"4": "Dialogue 4",
	"5": "Dialogue 5",
}

var dialogue_groups: Dictionary = {
	"1": ["1", "2", "3", "4", "5"]
}

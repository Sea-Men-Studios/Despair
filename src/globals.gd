extends Node

enum ItemType {NULL, NOTE_ITEM, IMPORTANT_ITEM}

var song_folder: String = "res://assets/audio/music/"
var songs: Array[AudioStreamMP3] = [
	load(song_folder + "Despair.mp3"),
	load(song_folder + "Act1_Entrapped.mp3"),
	load(song_folder + "Prologue_Itchy_Neck.mp3"),
	load(song_folder + "Your_Call_Has_Been_Forwarded.mp3"),
	load(song_folder + "Fight_Or_Flight.mp3"),
]

var notes: Dictionary = {
	"1": {"scene": load("res://scenes/lore_notes/LoreNote1.tscn")},
	"2": {"scene": load("res://scenes/lore_notes/LoreNote2.tscn")},
	"3": {"scene": load("res://scenes/lore_notes/LoreNote3.tscn")},
	"4": {"scene": load("res://scenes/lore_notes/LoreNote4.tscn")},
	"5": {"scene": load("res://scenes/lore_notes/LoreNote5.tscn")}
}

var key_items: Dictionary = {
	"1": {"scene": load("res://scenes/items/key_item.tscn"), "name": "Test Key Item"},
	"2": {"scene": load("res://scenes/items/radio.tscn"), "name": "Radio"},
	"3": {"scene": load("res://scenes/items/killeritem.tscn"), "name": "KILL"},
	"4": {"scene": load("res://scenes/items/batteries.tscn"), "name": "Batteries"},
}

var objectives: Dictionary = {
	"1": "Pick up the batteries",
	"2": "Place the batteries into the walkie talkie"
}

var dialogue_lines: Dictionary = {
	"1": "Hello? Respond. This channel has been silent for a very long time. Who is this? Over.",
	"2": "Alright, whoever you are, this is a private channel, present some form of authorization to even be using it in the first place. Over.",
	"3": "Your signal is authorised, level 2 access. I’m checking your credentials. Over.",
	"4": "So you're just an electrician..? I was hoping for someone more special. Over.",
	"5": "I guess you’ll do. As an employee of Orison: Bio-Solutions, it is your responsibility to follow company orders.",
	"6": "Not like there’s much else to do, go take a look outside for us. Over.",
	"7": "Are you there yet? Report back. Over.",
}

var dialogue_groups: Array = [
	["1", "2"],
	["3", "4", "5"],
]
	
var batteries_inserted: bool = false

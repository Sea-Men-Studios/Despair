extends Node

signal locker_left

enum ItemType {NULL, NOTE_ITEM, MISC_NOTE_ITEM, IMPORTANT_ITEM}

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
	"5": {"scene": load("res://scenes/lore_notes/LoreNote5.tscn")},
	"6": {"scene": load("res://scenes/lore_notes/LoreNote6.tscn")},
	"7": {"scene": load("res://scenes/lore_notes/LoreNote7.tscn")},
	"8": {"scene": load("res://scenes/lore_notes/LoreMisc1.tscn")},
	"9": {"scene": load("res://scenes/lore_notes/LoreMisc2.tscn")},
	"10": {"scene": load("res://scenes/lore_notes/LoreMisc3.tscn")},
	"11": {"scene": load("res://scenes/lore_notes/LoreMisc4.tscn")},
	"12": {"scene": load("res://scenes/lore_notes/LoreMisc5.tscn")},
	"13": {"scene": load("res://scenes/lore_notes/LoreMisc6.tscn")},
	"14": {"scene": load("res://scenes/lore_notes/LoreMisc7.tscn")},
	"15": {"scene": load("res://scenes/lore_notes/LoreMisc8.tscn")},
	"16": {"scene": load("res://scenes/lore_notes/LoreMisc9.tscn")},
	"17": {"scene": load("res://scenes/lore_notes/LoreMisc10.tscn")},
	"18": {"scene": load("res://scenes/lore_notes/LoreMisc11.tscn")},
	"19": {"scene": load("res://scenes/lore_notes/LoreMisc12.tscn")},
}

var key_items: Dictionary = {
	"1": {"scene": load("res://scenes/items/key_item.tscn"), "name": "Test Key Item"},
	"2": {"scene": load("res://scenes/items/radio.tscn"), "name": "Walkie Talkie"},
	"3": {"scene": load("res://scenes/items/killeritem.tscn"), "name": "KILL"},
	"4": {"scene": load("res://scenes/items/batteries.tscn"), "name": "Batteries"},
}

var objectives: Dictionary = {
	"1": "Pick up the batteries",
	"2": "Place the batteries into the walkie talkie",
	"3": "Collect all notes"
}

var dialogue_lines: Dictionary = {
	"1": "Hello? Respond. This channel has been silent for a very long time. Who is this? Over.",
	"2": "Alright, whoever you are, this is a private channel, present some form of authorization to even be using it in the first place. Over.",
	"3": "Your signal is authorised, level 2 access. I’m checking your credentials. Over.",
	"4": "So you're just an electrician..? I was hoping for someone more special. Over.",
	"5": "I guess you’ll do. As an employee of Orison: Bio-Solutions, it is your responsibility to follow company orders.",
	"6": "Not like there’s much else to do, go take a look outside for us. Over.",
	"7": "Are you there yet? Report back. Over.",
	"8": "I'm worried you've stopped prioritizing the mission and you're focusing on deliberately going out of your way to piss me off.",
	"9": "Forget the past of the company, don't even think about knowing more. Just get here and fix this. Over.",
	"10": "Report here immediately, we are sick of you messing with our stuff. Get here now.",
	"11": "The company now identifies you as a threat to our health and safety.",
	"12": "Orison Bio-Solutions has had no part in any of this. On to the next person.",
	"13": "Please remove yourself from this world and die with the information you have. You are fired. Over.",
	"14": "What is that thing? Whatever it is, keep your distance. If you die, the mission done for.",
	"15": "They seem to have horrible eyesight, hiding in a locker or standing behind them might help you get away. Over.",
}

var dialogue_groups: Array = [
	["1", "2"],
	["3", "4", "5"],
	["8", "9"],
	["10", "11", "12", "13"],
	["14", "15"]
]
	
var batteries_inserted: bool = false

var current_objectives: Dictionary = {}
var key_items_aquired: Dictionary = {}

func notify_locker_left() -> void:
	locker_left.emit()

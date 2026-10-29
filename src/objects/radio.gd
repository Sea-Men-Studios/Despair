extends InteractableObject

@export var item_id: int
@export var stream_player: AudioStreamPlayer

var beep_sound: AudioStreamMP3 = load("res://assets/audio/walkie talkie/radio send out signal.mp3")

var game
var dialogue_controller

func _ready():
	game = get_tree().current_scene
	
	held_orientation = Vector3(0, -30.0/180.0*PI, 0)
	set_item_type(Globals.ItemType.IMPORTANT_ITEM)

func use():
	game.dialogue_progress()
	
	stream_player.stream = beep_sound
	stream_player.play()

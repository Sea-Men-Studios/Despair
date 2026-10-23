extends Area3D

@export var music_controller: AudioStreamPlayer
@export var song_index: int

var toggled: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(area) -> void: 
	if area.name == "Player" and toggled == false:
		music_controller.set_song(song_index)
		toggled = false

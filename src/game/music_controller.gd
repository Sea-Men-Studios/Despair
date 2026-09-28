extends AudioStreamPlayer

var music_folder: String = "res://assets/audio/music/"

var music: Array[AudioStreamMP3] = [
	load(music_folder + "DespairV2.mp3"),
	load(music_folder + "Area_1_ALT__Entrapped.mp3"),
]

func _ready() -> void:
	var mp3: AudioStreamMP3 = music[1]
	volume_db = -10
	set_stream(mp3)
	play()

func _on_audio_stream_finished() -> void:
	play()

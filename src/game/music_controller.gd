extends AudioStreamPlayer

var regular_volume: int = -5
var fade_length: float = 1.5

var music_folder: String = "res://assets/audio/music/"

var music: Array[AudioStreamMP3] = [
	load(music_folder + "Despair.mp3"),
	load(music_folder + "Act1_Entrapped.mp3"),
	load(music_folder + "Prologue_Itchy_Neck.mp3")
]

var music_started: bool = false
var next_song_index: int = 0

func _ready() -> void:
	volume_db = -5
	set_song(0)

func _on_audio_stream_finished() -> void:
	play()

func set_song(index: int) -> void:
	if music_started == true:
		next_song_index = index
		var fade_out_tween = get_tree().create_tween()
		fade_out_tween.tween_property(self, "volume_db", -40, fade_length)
		fade_out_tween.tween_callback(start_next_song.bind(fade_out_tween))
	else:
		var mp3: AudioStreamMP3 = music[index]
		
		set_stream(mp3)
		#print("now playing: ", mp3)
		play()
		music_started = true

func start_next_song(object: Tween):
	object.stop()
	
	var mp3: AudioStreamMP3 = music[next_song_index]
	
	set_stream(mp3)
	#print("now playing: ", mp3)
	play()
	
	var fade_in_tween = get_tree().create_tween()
	fade_in_tween.tween_property(self, "volume_db", regular_volume, fade_length)
	fade_in_tween.tween_callback(end_fade_in.bind(fade_in_tween))

func end_fade_in(object: Tween):
	object.stop()

extends AudioStreamPlayer

@export var messages: Array[MorseMessage] = []

var current_index := 0

signal message_started(subtitle: String, audio: AudioStream)
signal message_finished(index: int)
signal all_messages_played

func play_next_message() -> void:
	if current_index >= messages.size():
		all_messages_played.emit()
		return
	var msg = messages[current_index]
	stream = msg.audio
	play()
	message_started.emit(msg.subtitle, msg.audio)

func _on_finished() -> void:
	message_finished.emit(current_index)
	current_index += 1

extends Node3D

@onready var settings_panel: TextureRect = $CanvasLayer/SettingsPanel
@onready var settings: Control = $CanvasLayer/SettingsPanel/Settings
@onready var main_pause_menu: Control = $CanvasLayer/SettingsPanel/MainPauseMenu
@onready var player = $Player
@onready var message_player: AudioStreamPlayer = $MessagePlayer
@onready var subtitle_label: RichTextLabel = $CanvasLayer/SubtitleLabel

@export var linger_time := 2.0
var subtitle_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	message_player.message_started.connect(_on_message_started)
	message_player.message_finished.connect(_on_message_finished)
	subtitle_label.text = ""
	subtitle_label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		settings_panel.visible = true
	if event.is_action_pressed("messsage_debug"):
		receive_message()


func _on_back_pressed() -> void:
		settings.visible = false
		main_pause_menu.visible = true

func _on_resume_pressed() -> void:
	settings_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_exit_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_settings_cog_button_pressed() -> void:
	settings.visible = true
	main_pause_menu.visible = false


func receive_message() -> void:
	
	message_player.play_next_message()

func _on_message_started(subtitle: String, audio: AudioStream) -> void:
	subtitle_label.text = subtitle
	subtitle_label.visible_characters = 0
	subtitle_label.visible = true
	subtitle_label.modulate.a = 1.0

	if subtitle_tween:
		subtitle_tween.kill()

	var duration = audio.get_length()

	subtitle_tween = create_tween()
	subtitle_tween.tween_property(subtitle_label, "visible_characters", subtitle.length(), duration)
	subtitle_tween.tween_interval(linger_time)
	subtitle_tween.tween_property(subtitle_label, "modulate:a", 0.0, 0.4)  # quick fade out
	subtitle_tween.tween_callback(func(): subtitle_label.visible = false)


func _on_message_finished(index: int) -> void:
	pass

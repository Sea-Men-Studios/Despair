extends Node3D

@onready var settings_panel: TextureRect = $GUI/SettingsPanel
@onready var settings: Control = $GUI/SettingsPanel/Settings
@onready var main_pause_menu: Control = $GUI/SettingsPanel/MainPauseMenu
@onready var controls: Control = $GUI/SettingsPanel/Controls
@onready var inventory: Control = $GUI/Inventory
@onready var player = $Player
@onready var message_player: AudioStreamPlayer = $MessagePlayer
@onready var music_player: AudioStreamPlayer = $MusicController
@onready var subtitle_label: RichTextLabel = $GUI/SubtitleLabel
@onready var objective_controller: Control = $GUI/Objectives
@onready var morse_code_test: AudioStreamOggVorbis = load("res://assets/audio/morsecodetest.ogg")

@export var linger_time := 2.0
@export var characters_per_second := 25.0

var subtitle_tween: Tween
var in_ui := false
var message_audio_active := false

var current_group_id := 0
var dialogue_group_over := false
var dialogue_id := 0
var can_progress_dialogue := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	subtitle_label.text = ""
	subtitle_label.visible = false
	message_player.finished.connect(_on_message_audio_finished)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if not in_ui:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event.is_action_pressed("ui_cancel") and not in_ui:
		in_ui = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		settings_panel.visible = true

	if event.is_action_pressed("inventory") and not in_ui:
		in_ui = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		inventory.load_items()
		inventory._change_tab("Items")
		inventory.visible = true

	# Make sure this action name matches Project Settings > Input Map.
	if event.is_action_pressed("message"):
		receive_message("Test Dialogue")


func receive_message(subtitle: String = "") -> void:
	# No argument: take the next line from Globals.
	# With an argument: display the supplied text directly.
	var is_forced = !subtitle.is_empty()
	
	if !is_forced:
		if dialogue_group_over:
			return

		if current_group_id >= Globals.dialogue_groups.size():
			return

		var message_group = Globals.dialogue_groups[current_group_id]

		if dialogue_id >= message_group.size():
			dialogue_group_over = true
			can_progress_dialogue = true
			return

		subtitle = Globals.dialogue_lines[message_group[dialogue_id]]
		dialogue_id += 1

		if dialogue_id >= message_group.size():
			dialogue_group_over = true
			can_progress_dialogue = true

	message_start(subtitle, is_forced)

	# Repeat the Morse sound until this message's subtitle sequence ends.
	message_player.stop()
	message_player.stream = morse_code_test
	message_player.volume_db = -35
	message_audio_active = true
	message_player.play()

func receive_group_message(group_id: int) -> void:
	can_progress_dialogue = true
	current_group_id = group_id
	dialogue_progress(false)

func message_start(subtitle: String, forced: bool) -> void:
	if subtitle_tween:
		subtitle_tween.kill()

	subtitle_label.text = subtitle
	subtitle_label.visible_characters = 0
	subtitle_label.visible = true
	subtitle_label.modulate.a = 1.0

	var typing_duration := float(subtitle.length()) / characters_per_second

	subtitle_tween = create_tween()
	subtitle_tween.tween_property(
		subtitle_label,
		"visible_characters",
		subtitle.length(),
		typing_duration
	)
	subtitle_tween.tween_interval(linger_time)
	subtitle_tween.tween_property(subtitle_label, "modulate:a", 0.0, 0.4)
	subtitle_tween.tween_callback(_on_message_text_finished.bind(forced))

func _on_message_audio_finished() -> void:
	if message_audio_active:
		message_player.play()


func _on_message_text_finished(forced: bool) -> void:
	message_audio_active = false
	message_player.stop()
	subtitle_label.visible = false

	# Continue automatically unless the dialogue group has ended.
	if not dialogue_group_over and not forced:
		receive_message()


func dialogue_progress(increase_group_id: bool = true) -> void:
	if not can_progress_dialogue:
		return

	can_progress_dialogue = false
	dialogue_group_over = false
	if increase_group_id: 
		current_group_id += 1
	dialogue_id = 0
	receive_message()


func _on_back_pressed() -> void:
	settings.visible = false
	main_pause_menu.visible = true


func _on_back_2_pressed() -> void:
	controls.visible = false
	main_pause_menu.visible = true


func _on_back_inventory_pressed() -> void:
	in_ui = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	inventory.visible = false


func _on_resume_pressed() -> void:
	in_ui = false
	settings_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_exit_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_controls_pressed() -> void:
	main_pause_menu.visible = false
	controls.visible = true


func _on_settings_cog_button_pressed() -> void:
	settings.visible = true
	main_pause_menu.visible = false

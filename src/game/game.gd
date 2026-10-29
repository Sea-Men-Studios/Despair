extends Node3D

@onready var settings_panel: TextureRect = $GUI/SettingsPanel
@onready var settings: Control = $GUI/SettingsPanel/Settings
@onready var main_pause_menu: Control = $GUI/SettingsPanel/MainPauseMenu
@onready var controls: Control = $GUI/SettingsPanel/Controls
@onready var inventory: Control = $GUI/Inventory
@onready var player = $Player
@onready var message_player: AudioStreamPlayer = $MessagePlayer
@onready var subtitle_label: RichTextLabel = $GUI/SubtitleLabel

@onready var morse_code_test: AudioStreamOggVorbis = load("res://assets/audio/morsecodetest.ogg")

@export var linger_time := 2.0
var subtitle_tween: Tween

var in_ui: bool = false

var current_group_id: int = 0
var dialogue_group_over: bool = false
var dialogue_id: int = 0
var can_progress_dialogue: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	message_player.finished.connect(_on_message_finished)
	subtitle_label.text = ""
	subtitle_label.visible = false
	receive_message()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
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

func receive_message() -> void:
	if dialogue_group_over == false:
		var message_group = Globals.dialogue_groups[current_group_id]
		var message = Globals.dialogue_lines[message_group[dialogue_id]]
		
		message_start(message)
		message_player.stream = morse_code_test
		message_player.play()
		
		dialogue_id += 1

		if dialogue_id >= Globals.dialogue_groups[current_group_id].size():
			dialogue_group_over = true
			can_progress_dialogue = true
			dialogue_id = 0

func message_start(subtitle: String) -> void:
	subtitle_label.text = ""
	subtitle_label.visible = true
	subtitle_label.modulate.a = 1.0

	if subtitle_tween:
		subtitle_tween.kill()

	var char_count = subtitle.length()
	var duration = subtitle.length() * 0.1
	var step_time = duration / char_count

	message_player.volume_db = -35
	subtitle_tween = create_tween()
	
	var text_buffer = [""]
	for i in range(char_count):
		var char_index = i
		subtitle_tween.tween_interval(step_time)
		subtitle_tween.tween_callback(func(): 
			text_buffer[0] += subtitle[char_index]
			subtitle_label.text = text_buffer[0]
		)
	
	subtitle_tween.tween_interval(linger_time)
	subtitle_tween.tween_property(subtitle_label, "modulate:a", 0.0, 0.4)
	subtitle_tween.tween_callback(_on_message_text_finished)

func dialogue_progress() -> void:
	print(can_progress_dialogue)
	if can_progress_dialogue == true:
		can_progress_dialogue = false
		dialogue_group_over = false
		current_group_id += 1
		receive_message()

func _on_message_text_finished() -> void:
	message_player.volume_db = -100
	subtitle_label.visible = false
	
	if dialogue_group_over == false:
		receive_message()
	
func _on_message_finished() -> void:
	message_player.play()

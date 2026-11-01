extends Node3D

@onready var settings_panel: TextureRect = $GUI/SettingsPanel
@onready var settings: Control = $GUI/SettingsPanel/Settings
@onready var main_pause_menu: Control = $GUI/SettingsPanel/MainPauseMenu
@onready var player = $Player
@onready var message_player: AudioStreamPlayer = $MessagePlayer
@onready var subtitle_label: RichTextLabel = $GUI/SubtitleLabel
@onready var area_3d: Area3D = $World/Area3D



@export var linger_time := 2.0
@export var characters_per_second := 25.0

var subtitle_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	subtitle_label.text = ""
	subtitle_label.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		settings_panel.visible = true

	if event.is_action_pressed("messsage_debug"):
		receive_message("Test Dialogue")

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

func receive_message(subtitle: String) -> void:
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
	subtitle_tween.tween_callback(func(): subtitle_label.visible = false)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		receive_message("This is a test dialogue")
		$World/Area3D/CollisionShape3D.disabled = true
	

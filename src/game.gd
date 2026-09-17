extends Node3D

@onready var settings_panel: TextureRect = $SettingsPanel
@onready var settings: Control = $SettingsPanel/Settings
@onready var main_pause_menu: Control = $SettingsPanel/MainPauseMenu



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		settings_panel.visible = true
		


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
	print("balls")

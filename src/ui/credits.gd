extends CanvasLayer

@onready var despair: Label = $Despair
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var music: AudioStreamPlayer = $Music
@onready var logo: TextureRect = $Logo
@onready var godot_logo: TextureRect = $GodotLogo

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	despair.position.y -= 0.1
	rich_text_label.position.y -= 0.1
	logo.position.y -= 0.1
	godot_logo.position.y -= 0.1
	if godot_logo.position.y <= 500:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

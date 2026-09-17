extends VSlider
@onready var fo_v_num: Label = $FoVNum


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	fo_v_num.text = str(value)

func _on_value_changed(value: float) -> void:
	Settings.fov = value

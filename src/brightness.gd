extends VSlider
@onready var brightness_num: Label = $BrightnessNum


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	min_value = 0.3
	max_value = 1.5
	step = 0.05
	value = Settings.brightness


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	brightness_num.text = str(value)


func _on_value_changed(value: float) -> void:
	Settings.brightness = value

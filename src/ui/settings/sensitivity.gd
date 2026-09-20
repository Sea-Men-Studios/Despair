extends VSlider
@onready var sens_num: Label = $Sensitivity/SensNum


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	min_value = 0.001
	max_value = 0.01
	step = 0.0005
	value = Settings.sensitivity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sens_num.text = str(value)


func _on_value_changed(value: float) -> void:
	Settings.sensitivity = value

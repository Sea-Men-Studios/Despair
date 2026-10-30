extends VSlider


@onready var volume_num: Label = $VolumeNum


func _process(_delta: float) -> void:
	volume_num.text = str(value) 
func _ready() -> void:
	# Set the slider from the global value without firing value_changed.
	set_value_no_signal(Settings.volume)
	_update_label(value)

	if not value_changed.is_connected(_on_value_changed):
		value_changed.connect(_on_value_changed)


func _on_value_changed(new_value: float) -> void:
	Settings.volume = new_value
	_update_label(new_value)


func _update_label(new_value: float) -> void:
	volume_num.text = str(roundi(new_value))
	

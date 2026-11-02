extends Control

@onready var objective_font: FontFile = load("res://assets/fonts/DemonSker-zyzD.ttf")

@export var objective_container: Container

var fade_length: float = 1.5

func _ready() -> void:
	visible = true
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	if get_tree().current_scene.name == "PrologueLevel":
		add_objective("1")
	elif get_tree().current_scene.name == "Map":
		add_objective("5")

func add_objective(id: String) -> void:	
	var objective = Label.new()
	objective.set("theme_override_fonts/font", objective_font)
	objective.set("theme_override_font_sizes/font_size", 32)
	objective.text = "- " + Globals.objectives[id]
	objective_container.add_child(objective)
	
	Globals.current_objectives[id] = objective
	
	var fade_in_tween = get_tree().create_tween()
	fade_in_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), fade_length).set_trans(Tween.TRANS_QUAD)
	fade_in_tween.tween_callback(fade_in_tween.stop)

func complete_objective(id: String) -> void:
	Globals.current_objectives[id].queue_free()
	Globals.current_objectives.erase(id)
	
	if Globals.current_objectives.size() == 0:
		var fade_out_tween = get_tree().create_tween()
		fade_out_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), fade_length).set_trans(Tween.TRANS_QUAD)
		fade_out_tween.tween_callback(fade_out_tween.stop)

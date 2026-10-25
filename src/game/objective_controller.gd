extends Control

var current_objectives: Array = ["1"]

func add_objective(id: String) -> void:
	current_objectives.append(id)

func complete_objective(id: String) -> void:
	print("completed " + id)
	current_objectives.erase(id)

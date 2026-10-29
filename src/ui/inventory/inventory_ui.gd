extends Control

@export var player: CharacterBody3D
@export var buttons: Container
@export var panels: Container

var tab_names: Array[String] = ["Items", "Notes"]
var tabs: Array[Dictionary]

func _ready() -> void:
	for tab_name in tab_names:
		var button: Button = buttons.find_child(tab_name + "Button")
		var panel: PanelContainer = panels.find_child(tab_name + "Panel")
		
		button.pressed.connect(_change_tab.bind(tab_name))
		
		tabs.append({
			"name": tab_name,
			"button": button,
			"panel": panel
		})

func _change_tab(tab_name: String) -> void:
	for tab in tabs:
		if tab["name"] == tab_name:
			tab["panel"].visible = true
		else:
			tab["panel"].visible = false

func load_items() -> void:
	for tab in tabs:
		tab["panel"].load_content(self)

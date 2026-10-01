extends Control

func _ready() -> void:
	$RestartButton.pressed.connect(_on_restart_pressed)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

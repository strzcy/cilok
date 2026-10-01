extends Control

func _ready() -> void:
	$ResumeButton.pressed.connect(_on_resume_pressed)

func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()

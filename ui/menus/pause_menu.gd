extends CanvasLayer

func _ready() -> void:
	$PauseOverlay.hide()

func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$PauseOverlay.show()
	$PauseButton.hide()

func _on_play_button_pressed() -> void:
	get_tree().paused = false
	$PauseOverlay.hide()
	$PauseButton.show()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/menus/level_selection.tscn")

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

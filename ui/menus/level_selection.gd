extends Control

@onready var grid = $LevelGrid

var btn_scene = preload("res://ui/menus/level_button.tscn")

func _ready() -> void:
	var unlocked = SaveManager.get_highest_unlocked_level()
	for i in range(1, 26):
		var btn = btn_scene.instantiate()
		btn.text = str(i)
		btn.disabled = (i > unlocked)
		var capture_id = i
		btn.pressed.connect(func(): _on_level_btn_pressed(capture_id))
		grid.add_child(btn)

func _on_level_btn_pressed(level_id: int) -> void:
	SaveManager.current_playing_level = level_id
	get_tree().change_scene_to_file("res://levels/level_" + str(level_id) + ".tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/menus/save_selection.tscn")

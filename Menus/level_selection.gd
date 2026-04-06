extends Control

@onready var grid = $LevelGrid

func _ready() -> void:
	var unlocked = SaveManager.get_highest_unlocked_level()
	var tex = load("res://Assets/Signage.png")
	for i in range(1, 26):
		var btn = Button.new()
		
		var bg = NinePatchRect.new()
		bg.texture = tex
		bg.region_rect = Rect2(0, 0, 32, 32)
		bg.patch_margin_left = 10
		bg.patch_margin_top = 6
		bg.patch_margin_right = 10
		bg.patch_margin_bottom = 4
		bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bg.show_behind_parent = true
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.add_child(bg)
		
		btn.text = str(i)
		btn.custom_minimum_size = Vector2(80, 80)
		btn.add_theme_font_size_override("font_size", 24)
		btn.disabled = (i > unlocked)
		var capture_id = i
		btn.pressed.connect(func(): _on_level_btn_pressed(capture_id))
		grid.add_child(btn)

func _on_level_btn_pressed(level_id: int) -> void:
	SaveManager.current_playing_level = level_id
	get_tree().change_scene_to_file("res://Levels/level_" + str(level_id) + ".tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/save_selection.tscn")

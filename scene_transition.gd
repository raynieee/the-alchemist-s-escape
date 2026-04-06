extends CanvasLayer

var color_rect: ColorRect
var day_label: Label

func _ready() -> void:
	layer = 100
	
	color_rect = ColorRect.new()
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.color = Color.BLACK
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(color_rect)
	
	day_label = Label.new()
	day_label.text = "Day 1"
	day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	day_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	day_label.add_theme_font_size_override("font_size", 64)
	color_rect.add_child(day_label)

func transition_to_next_day(day_number: int) -> void:
	day_label.text = "Day " + str(day_number)
	
	# Fade to black
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	get_tree().change_scene_to_file("res://Levels/level_" + str(day_number) + ".tscn")
	
	# Wait a bit
	await get_tree().create_timer(1.0).timeout
	
	# Fade back
	var tween2 = create_tween()
	tween2.tween_property(color_rect, "modulate:a", 0.0, 0.5)

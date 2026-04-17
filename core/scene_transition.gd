extends CanvasLayer

var color_rect: ColorRect
var day_word_label: Label
var day_number_label: Label
var english_towne_font = load("res://assets/fonts/EnglishTowne.ttf")
var nickburg_font = load("res://assets/fonts/Nickburg.otf")

func _ready() -> void:
	layer = 100
	
	color_rect = ColorRect.new()
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.color = Color.BLACK
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(color_rect)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_CENTER)
	hbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	hbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 15)
	color_rect.add_child(hbox)
	
	day_word_label = Label.new()
	day_word_label.text = "DAY"
	day_word_label.add_theme_font_size_override("font_size", 64)
	day_word_label.add_theme_font_override("font", nickburg_font)
	hbox.add_child(day_word_label)
	
	day_number_label = Label.new()
	day_number_label.text = "1"
	day_number_label.add_theme_font_size_override("font_size", 108)
	day_number_label.add_theme_font_override("font", english_towne_font)
	hbox.add_child(day_number_label)

func transition_to_next_day(day_number: int) -> void:
	day_number_label.text = str(day_number)
	
	# Fade to black
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	get_tree().change_scene_to_file("res://levels/level_" + str(day_number) + ".tscn")
	
	# Wait a bit
	await get_tree().create_timer(1.0).timeout
	
	# Fade back
	var tween2 = create_tween()
	tween2.tween_property(color_rect, "modulate:a", 0.0, 0.5)

extends CanvasLayer

signal dialogue_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var label: RichTextLabel = $Panel/VBoxContainer/RichTextLabel
@onready var _timer: Timer = $Timer

var dialogue_queue: Array[String] = []
var is_typing := false

func _ready() -> void:
	color_rect.gui_input.connect(_on_background_gui_input)
	_timer.timeout.connect(_on_timer_timeout)
	hide()
	
func is_active() -> bool:
	return visible

func show_dialogue(lines: Array) -> void:
	dialogue_queue.clear()
	for line in lines:
		dialogue_queue.append(str(line))
		
	show()
	_show_next_line()

func _show_next_line() -> void:
	if dialogue_queue.is_empty():
		hide()
		dialogue_finished.emit()
		return

	var current_text = dialogue_queue.pop_front()
	label.text = "[center]" + current_text + "[/center]"
	label.visible_characters = 0
	is_typing = true
	_timer.start(0.04)

func _on_timer_timeout() -> void:
	label.visible_characters += 1
	if label.visible_ratio >= 1.0 or label.visible_characters >= label.get_parsed_text().length():
		is_typing = false
		_timer.stop()

func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_handle_input()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_input()

func _handle_input() -> void:
	if not visible:
		return
	else:
		_show_next_line()

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event is InputEventScreenTouch and event.pressed:
		get_viewport().set_input_as_handled()
		_handle_input()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		_handle_input()

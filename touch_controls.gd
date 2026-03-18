extends CanvasLayer

@onready var left: TouchScreenButton = $Left
@onready var right: TouchScreenButton = $Right
@onready var jump: TouchScreenButton = $Jump

@export var action_left := "p1_left"
@export var action_right := "p1_right"
@export var action_jump := "p1_jump"

func _on_left_pressed() -> void:
	left.modulate.a = 0.5
	Input.action_press(action_left)

func _on_left_released() -> void:
	left.modulate.a = 1.0
	Input.action_release(action_left)

func _on_right_pressed() -> void:
	right.modulate.a = 0.5
	Input.action_press(action_right)

func _on_right_released() -> void:
	right.modulate.a = 1.0
	Input.action_release(action_right)

func _on_jump_pressed() -> void:
	jump.modulate.a = 0.5
	Input.action_press(action_jump)

func _on_jump_released() -> void:
	jump.modulate.a = 1.0
	Input.action_release(action_jump)

extends CanvasLayer

@onready var left: TouchScreenButton = $Control/Left
@onready var right: TouchScreenButton = $Control/Right
@onready var jump: TouchScreenButton = $Control/Jump
@onready var interact: TouchScreenButton = $Control/Interact

@export var action_left := "p1_left"
@export var action_right := "p1_right"
@export var action_jump := "p1_jump"
@export var action_interact := "p1_interact"

func _ready() -> void:
	left.passby_press = true
	right.passby_press = true
	jump.passby_press = true
	interact.passby_press = true

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
	
func _on_interact_pressed() -> void:
	interact.modulate.a = 0.5
	Input.action_press(action_interact)

func _on_interact_released() -> void:
	interact.modulate.a = 1.0
	Input.action_release(action_interact)

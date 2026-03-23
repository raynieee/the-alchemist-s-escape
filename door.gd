extends StaticBody2D

@export var required_sum_text: String = ""

@onready var area = $Area2D
@onready var block_collision = $CollisionShape2D
@onready var color_rect = $ColorRect
@onready var win_layer = $CanvasLayer
@onready var sum_label = $RequiredSumLabel

var players_at_door: Array[Node2D] = []

func _ready() -> void:
	area.monitoring = false
	win_layer.hide()
	area.body_exited.connect(_on_area_2d_body_exited)
	if required_sum_text != "":
		sum_label.text = required_sum_text

func open() -> void:
	# Disable the blocking collision
	block_collision.set_deferred("disabled", true)
	color_rect.color = Color(0, 1, 0, 0.4)
	# Enable the area detection
	area.set_deferred("monitoring", true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Quick check if it is the player
	if body.name.begins_with("Player"):
		if not body in players_at_door:
			players_at_door.append(body)
			
		if players_at_door.size() >= 2:
			_complete_level()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name.begins_with("Player"):
		if body in players_at_door:
			players_at_door.erase(body)

func _complete_level() -> void:
	win_layer.show()
	get_tree().paused = true
	SaveManager.complete_level(SaveManager.current_playing_level)

func _on_next_level_pressed() -> void:
	get_tree().paused = false
	if SaveManager.current_playing_level < 25:
		SaveManager.current_playing_level += 1
		get_tree().change_scene_to_file("res://Levels/level_" + str(SaveManager.current_playing_level) + ".tscn")
	else:
		get_tree().change_scene_to_file("res://Menus/level_selection.tscn")

func _on_level_selection_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/level_selection.tscn")

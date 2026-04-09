extends Node2D

@onready var player1: Node2D = $Player
@onready var player2: Node2D = $Player2
@onready var lectern: Node2D = $Lectern
@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var door_block: Node2D = $DoorBlock

enum LevelState { START, MOVING_RIGHT, FIND_BUTTON, WAITING_FOR_LECTERN, FINISHED }
var current_state: LevelState = LevelState.START

var start_x: float = 0

func _ready() -> void:
	if lectern:
		lectern.defer_level_transition = true
		lectern.puzzle_solved.connect(_on_puzzle_solved)
		
	if dialogue_ui:
		dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	
	if player1:
		start_x = player1.global_position.x
	
	call_deferred("_start_intro_dialogue")

func _start_intro_dialogue() -> void:
	if dialogue_ui:
		dialogue_ui.show_dialogue([
			"The lectern requires the right amount of potency (those numbers you see above the potions). You must submit two potions to reach what the lectern requires."
		])

func _process(_delta: float) -> void:
	if not dialogue_ui: return
	
	if current_state == LevelState.START and not dialogue_ui.is_active():
		current_state = LevelState.MOVING_RIGHT
		
	if current_state == LevelState.MOVING_RIGHT and not dialogue_ui.is_active():
		if player1 and player2:
			# Check if either player moved right by roughly 5 blocks (160 pixels)
			if player1.global_position.x > start_x + 160 or player2.global_position.x > start_x + 160:
				current_state = LevelState.FIND_BUTTON
				dialogue_ui.show_dialogue([
					"Sometimes things aren't as they seem. Find a way to get to those potions."
				])
				
	if current_state == LevelState.FIND_BUTTON and not dialogue_ui.is_active():
		if door_block and door_block.get("is_open"):
			# Button was pressed, door block is open
			current_state = LevelState.WAITING_FOR_LECTERN
			dialogue_ui.show_dialogue([
				"One of you, go get a potion there."
			])

func _on_puzzle_solved() -> void:
	if current_state != LevelState.FINISHED:
		current_state = LevelState.FINISHED
		dialogue_ui.show_dialogue([
			"Good. See you again tomorrow."
		])

func _on_dialogue_finished() -> void:
	if current_state == LevelState.FINISHED:
		SaveManager.complete_level(SaveManager.current_playing_level)
		if SaveManager.current_playing_level < 25:
			SaveManager.current_playing_level += 1
			SceneTransition.transition_to_next_day(SaveManager.current_playing_level)
		else:
			get_tree().change_scene_to_file("res://Menus/level_selection.tscn")

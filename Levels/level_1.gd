extends Node2D

@onready var player1: Node2D = $Player
@onready var player2: Node2D = $Player2
@onready var lectern: Node2D = $Lectern
@onready var dialogue_ui: CanvasLayer = $DialogueUI

enum LevelState { START, WAITING_FOR_POTIONS, WAITING_FOR_LECTERN, FINISHED }
var current_state: LevelState = LevelState.START

func _ready() -> void:
	# Setup initial state
	if lectern:
		lectern.defer_level_transition = true
		lectern.puzzle_solved.connect(_on_puzzle_solved)
		
	# Connect to dialogue finish
	if dialogue_ui:
		dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	
	# Start introductory dialogue
	# We slightly defer starting dialogue to ensure scene is loaded
	call_deferred("_start_intro_dialogue")

func _start_intro_dialogue() -> void:
	if dialogue_ui:
		dialogue_ui.show_dialogue([
			"Well since you're here, might as well help me with making the barrier stronger.",
			"See those potions on the floor? Pick them up."
		])

func _process(delta: float) -> void:
	if current_state == LevelState.START and dialogue_ui and not dialogue_ui.is_active():
		current_state = LevelState.WAITING_FOR_POTIONS
		
	if current_state == LevelState.WAITING_FOR_POTIONS:
		if _both_players_have_potions():
			current_state = LevelState.WAITING_FOR_LECTERN
			dialogue_ui.show_dialogue([
				"Great. Bring them to the lectern. It's that stand over there with a book on top."
			])

func _both_players_have_potions() -> bool:
	if not player1 or not player2:
		return false
	return (player1.get("held_item") != null) and (player2.get("held_item") != null)

func _on_puzzle_solved() -> void:
	if current_state == LevelState.WAITING_FOR_LECTERN:
		current_state = LevelState.FINISHED
		dialogue_ui.show_dialogue([
			"Great. Same time tomorrow."
		])

func _on_dialogue_finished() -> void:
	if current_state == LevelState.FINISHED:
		# Final dialgoue completed, transition level manually
		SaveManager.complete_level(SaveManager.current_playing_level)
		if SaveManager.current_playing_level < 25:
			SaveManager.current_playing_level += 1
			SceneTransition.transition_to_next_day(SaveManager.current_playing_level)
		else:
			get_tree().change_scene_to_file("res://Menus/level_selection.tscn")

extends Node2D

@onready var player1: Node2D = $Player
@onready var player2: Node2D = $Player2
@onready var lectern: Node2D = $Lectern
@onready var dialogue_ui: CanvasLayer = $DialogueUI

enum LevelState { START, EXPLORING, FOUND_LECTERN, WAITING_FOR_LECTERN, FINISHED }
var current_state: LevelState = LevelState.START

const LECTERN_DETECT_DISTANCE: float = 120.0

func _ready() -> void:
	if lectern:
		lectern.defer_level_transition = true
		lectern.puzzle_solved.connect(_on_puzzle_solved)
		
	if dialogue_ui:
		dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	
	call_deferred("_start_intro_dialogue")

func _start_intro_dialogue() -> void:
	if dialogue_ui:
		dialogue_ui.show_dialogue([
			"We need to divide to conquer this obstacle.",
			"Find the right potencies to synthesize the exact fraction."
		])

func _process(_delta: float) -> void:
	if not dialogue_ui: return
	
	if current_state == LevelState.START and not dialogue_ui.is_active():
		current_state = LevelState.EXPLORING
		
	if current_state == LevelState.EXPLORING and not dialogue_ui.is_active():
		if _player_near_lectern():
			current_state = LevelState.FOUND_LECTERN
			dialogue_ui.show_dialogue([
				"The green glow means this lectern requires division.",
				"Choose carefully which potencies to pick up."
			])
	
	if current_state == LevelState.FOUND_LECTERN and not dialogue_ui.is_active():
		current_state = LevelState.WAITING_FOR_LECTERN

func _player_near_lectern() -> bool:
	if not lectern: return false
	var lectern_pos = lectern.global_position
	if player1 and player1.global_position.distance_to(lectern_pos) < LECTERN_DETECT_DISTANCE:
		return true
	if player2 and player2.global_position.distance_to(lectern_pos) < LECTERN_DETECT_DISTANCE:
		return true
	return false

func _on_puzzle_solved() -> void:
	if current_state != LevelState.FINISHED:
		current_state = LevelState.FINISHED
		dialogue_ui.show_dialogue([
			"Good. We are done here."
		])

func _on_dialogue_finished() -> void:
	if current_state == LevelState.FINISHED:
		SaveManager.complete_level(SaveManager.current_playing_level)
		if SaveManager.current_playing_level < 25:
			SaveManager.current_playing_level += 1
			SceneTransition.transition_to_next_day(SaveManager.current_playing_level)
		else:
			get_tree().change_scene_to_file("res://Menus/level_selection.tscn")

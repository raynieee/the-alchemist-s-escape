extends Node

const SAVE_DIR = "user://"

var current_save_slot: int = -1
var current_save_data: Dictionary = {}
var current_playing_level: int = 1

func _ready() -> void:
	pass

func save_game() -> void:
	if current_save_slot < 0:
		push_error("No save slot selected!")
		return
	
	var file_path = SAVE_DIR + "save_" + str(current_save_slot) + ".save"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_var(current_save_data)
		print("Saved to slot ", current_save_slot)
	else:
		push_error("Could not open file for writing: ", file_path)

func load_game(slot_id: int) -> bool:
	var file_path = SAVE_DIR + "save_" + str(slot_id) + ".save"
	if not FileAccess.file_exists(file_path):
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var data = file.get_var()
		if typeof(data) == TYPE_DICTIONARY:
			current_save_slot = slot_id
			current_save_data = data
			print("Loaded save from slot ", slot_id)
			return true
	return false

func get_save_info(slot_id: int) -> Dictionary:
	var file_path = SAVE_DIR + "save_" + str(slot_id) + ".save"
	if not FileAccess.file_exists(file_path):
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var data = file.get_var()
		if typeof(data) == TYPE_DICTIONARY:
			return data
	return {}

func get_highest_unlocked_level() -> int:
	if current_save_data.has("highest_unlocked_level"):
		return current_save_data["highest_unlocked_level"]
	return 1

func complete_level(level_id: int) -> void:
	var highest = get_highest_unlocked_level()
	if level_id >= highest:
		current_save_data["highest_unlocked_level"] = level_id + 1
		save_game()

func create_new_save(slot_id: int, p1_name: String, p2_name: String) -> void:
	current_save_slot = slot_id
	current_save_data = {
		"account_name": p1_name + " & " + p2_name,
		"player_1_name": p1_name,
		"player_2_name": p2_name,
		"highest_unlocked_level": 1,
		"creation_time": Time.get_datetime_string_from_system()
	}
	save_game()

func delete_save(slot_id: int) -> void:
	var file_path = SAVE_DIR + "save_" + str(slot_id) + ".save"
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		if current_save_slot == slot_id:
			current_save_slot = -1
			current_save_data = {}

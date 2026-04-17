extends Control

@onready var slot_1 = $VBoxContainer/HBoxContainer/Slot1Button
@onready var slot_2 = $VBoxContainer/HBoxContainer/Slot2Button
@onready var slot_3 = $VBoxContainer/HBoxContainer/Slot3Button

@onready var name_dialog = $NameDialog
@onready var name_input = $NameDialog/Panel/VBoxContainer/NameInput

@onready var action_dialog = $ActionDialog
@onready var confirm_delete_dialog = $ConfirmDeleteDialog

var pending_slot_id: int = -1

func _ready() -> void:
	name_dialog.hide()
	action_dialog.hide()
	confirm_delete_dialog.hide()
	
	# Connect slots programmatically to fix editor linking bugs
	slot_1.pressed.connect(func(): _on_slot_button_pressed(1))
	slot_2.pressed.connect(func(): _on_slot_button_pressed(2))
	slot_3.pressed.connect(func(): _on_slot_button_pressed(3))
	
	name_input.max_length = 12
	update_slot_buttons()

func update_slot_buttons() -> void:
	var slots = [slot_1, slot_2, slot_3]
	
	for i in range(3):
		var slot_id = i + 1
		var info = SaveManager.get_save_info(slot_id)
		
		slots[i].clip_text = true
		if info.is_empty():
			slots[i].text = "Slot %d:\nEmpty" % slot_id
		else:
			var acct_name = info.get("account_name", "Unknown")
			slots[i].text = "Slot %d:\n%s" % [slot_id, acct_name]

func _on_slot_button_pressed(slot_id: int) -> void:
	var info = SaveManager.get_save_info(slot_id)
	
	if info.is_empty():
		# Ask for name
		pending_slot_id = slot_id
		name_input.text = ""
		name_dialog.show()
		name_input.grab_focus()
	else:
		# Ask for action (Play or Delete)
		pending_slot_id = slot_id
		action_dialog.show()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://core/main.tscn")

func _on_cancel_button_pressed() -> void:
	name_dialog.hide()
	pending_slot_id = -1

func _on_action_cancel_pressed() -> void:
	action_dialog.hide()
	pending_slot_id = -1

func _on_action_play_pressed() -> void:
	if pending_slot_id > 0:
		if SaveManager.load_game(pending_slot_id):
			get_tree().change_scene_to_file("res://ui/menus/level_selection.tscn")

func _on_action_delete_pressed() -> void:
	if pending_slot_id > 0:
		confirm_delete_dialog.show()

func _on_confirm_delete_yes_pressed() -> void:
	if pending_slot_id > 0:
		SaveManager.delete_save(pending_slot_id)
		confirm_delete_dialog.hide()
		action_dialog.hide()
		pending_slot_id = -1
		update_slot_buttons()

func _on_confirm_delete_no_pressed() -> void:
	confirm_delete_dialog.hide()

func _on_confirm_button_pressed() -> void:
	var acct_name = name_input.text.strip_edges()
	if acct_name == "":
		acct_name = "Player" # Default fallback
		
	if pending_slot_id > 0:
		SaveManager.create_new_save(pending_slot_id, acct_name)
		get_tree().change_scene_to_file("res://ui/menus/level_selection.tscn")

extends StaticBody2D

@export var required_sum: int = 4
@export var required_items_count: int = 2

enum Operator { ADD, SUB, MUL, DIV }
@export var operation: Operator = Operator.ADD

var submitted_values: Array[int] = []
var items_submitted: int = 0
var is_unlocked: bool = false
var players_who_submitted: Array[Node] = []

@onready var interactable: Area2D = $Interactable
@onready var sum_label: Label = $RequiredSumLabel

func _ready() -> void:
	interactable.interact = _on_interact
	if sum_label:
		sum_label.text = str(required_sum)

func _on_interact(interactor: Node = null) -> void:
	if is_unlocked:
		print("Already unlocked!")
		return
	
	if interactor in players_who_submitted:
		print("This player has already submitted a potion!")
		return
		
	if interactor and interactor.has_method("remove_held_item"):
		var item = interactor.remove_held_item()
		
		if item != null:
			var value = 0
			if "item_value" in item:
				value = item.item_value
			else:
				print("Warning: Item doesn't have an item_value property, treating as 0.")
				
			submitted_values.append(value)
			items_submitted += 1
			players_who_submitted.append(interactor)
			
			# Physically destroy the item now that the lectern "consumed" it
			item.queue_free()
			print("Lectern accepted item (Value: ", value, ")!")
			
			if items_submitted >= required_items_count:
				var ans = 0
				if submitted_values.size() == 1:
					ans = submitted_values[0]
				else:
					if operation == Operator.ADD:
						ans = submitted_values[0] + submitted_values[1]
					elif operation == Operator.SUB:
						ans = abs(submitted_values[0] - submitted_values[1])
					elif operation == Operator.MUL:
						ans = submitted_values[0] * submitted_values[1]
					elif operation == Operator.DIV:
						var a = max(submitted_values[0], submitted_values[1])
						var b = max(1, min(submitted_values[0], submitted_values[1]))
						ans = a / b
						
				if ans == required_sum:
					_unlock_door()
				else:
					print("Submission Failed! Incorrect potion combination. Expected ans ", required_sum, " got ", ans)
					# Reset the puzzle for the next attempt
					submitted_values.clear()
					items_submitted = 0
					players_who_submitted.clear()
		else:
			print("You aren't holding any item to submit!")

func _unlock_door() -> void:
	is_unlocked = true
	interactable.is_interactable = false
	print("Success! The right potions were mixed! Moving to next day.")
	
	SaveManager.complete_level(SaveManager.current_playing_level)
	if SaveManager.current_playing_level < 25:
		SaveManager.current_playing_level += 1
		SceneTransition.transition_to_next_day(SaveManager.current_playing_level)
	else:
		get_tree().change_scene_to_file("res://Menus/level_selection.tscn")

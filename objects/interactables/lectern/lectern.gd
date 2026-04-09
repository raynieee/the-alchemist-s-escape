extends StaticBody2D

signal puzzle_solved

enum Operator { ADD, SUB, MUL, DIV, RATIO }
@export var operation: Operator = Operator.ADD

@export_group("Basic Arithmetic Settings")
@export var required_target: float = 4.0 # Changed to float to support 3.5, 4.5, etc.

@export_group("Ratio Settings")
@export var required_ratio: Vector2i = Vector2i(1, 2)

@export_group("General Puzzle Settings")
@export var required_items_count: int = 2
@export var defer_level_transition: bool = false

# Array changed to float to hold decimal values
var submitted_values: Array[float] = [] 
var items_submitted: int = 0
var is_unlocked: bool = false
var players_who_submitted: Array[Node] = []

@onready var interactable: Area2D = $Interactable
@onready var sum_label: Label = $RequiredSumLabel

var glow_light: PointLight2D

func _ready() -> void:
	interactable.interact = _on_interact
	if sum_label:
		if operation == Operator.RATIO:
			sum_label.text = str(required_ratio.x) + ":" + str(required_ratio.y)
		else:
			if floor(required_target) == required_target:
				sum_label.text = str(int(required_target))
			else:
				sum_label.text = str(required_target)
	
	_create_glow_light()

func _create_glow_light() -> void:
	glow_light = PointLight2D.new()
	glow_light.position = Vector2(0, -5)
	
	# Set color based on operation
	var glow_color: Color
	match operation:
		Operator.ADD:
			glow_color = Color(1.0, 0.2, 0.2, 1.0) # Red
		Operator.SUB:
			glow_color = Color(0.2, 0.4, 1.0, 1.0) # Blue
		Operator.MUL:
			glow_color = Color(1.0, 0.9, 0.2, 1.0) # Yellow
		Operator.DIV:
			glow_color = Color(0.2, 0.9, 0.3, 1.0) # Green
		Operator.RATIO:
			glow_color = Color(1.0, 0.4, 0.7, 1.0) # Pink
	
	glow_light.color = glow_color
	glow_light.energy = 1.5
	glow_light.texture_scale = 0.15
	
	# Create a simple gradient texture for the light
	var gradient_tex = GradientTexture2D.new()
	gradient_tex.width = 128
	gradient_tex.height = 128
	gradient_tex.fill = GradientTexture2D.FILL_RADIAL
	gradient_tex.fill_from = Vector2(0.5, 0.5)
	gradient_tex.fill_to = Vector2(0.5, 0.0)
	var gradient = Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient_tex.gradient = gradient
	
	glow_light.texture = gradient_tex
	add_child(glow_light)
	
	# Pulsing animation
	_start_pulse()

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
			var value: float = 0.0
			if "item_value" in item:
				value = float(item.item_value) # Ensure it's read as a float
			else:
				print("Warning: Item doesn't have an item_value property, treating as 0.0.")
				
			submitted_values.append(value)
			items_submitted += 1
			players_who_submitted.append(interactor)
			
			item.queue_free()
			print("Lectern accepted item (Value: ", value, ")!")
			
			if items_submitted >= required_items_count:
				var is_correct = false
				
				match operation:
					Operator.RATIO:
						if submitted_values.size() >= 2:
							var sorted_vals = submitted_values.duplicate()
							sorted_vals.sort() 
							
							var val1 = sorted_vals[0]
							var val2 = sorted_vals[1]
							
							# Sort the required ratio values to match our sorted inputs
							var req_min = min(required_ratio.x, required_ratio.y)
							var req_max = max(required_ratio.x, required_ratio.y)
							
							# Cross multiply to check ratio (val1 / val2 == req_min / req_max)
							# This safely handles floats without needing a GCD function!
							var cross_1 = val1 * req_max
							var cross_2 = val2 * req_min
							
							if is_equal_approx(cross_1, cross_2):
								is_correct = true
							else:
								print("Submission Failed! Incorrect ratio.")
					
					Operator.ADD, Operator.SUB, Operator.MUL, Operator.DIV:
						var ans: float = 0.0
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
								var b = max(0.0001, min(submitted_values[0], submitted_values[1])) # Avoid exact 0 division
								ans = a / b
						
						# is_equal_approx handles tiny math rounding errors Godot might make
						if is_equal_approx(ans, required_target):
							is_correct = true
						else:
							print("Submission Failed! Expected ans ", required_target, " got ", ans)
				
				# FINAL EVALUATION
				if is_correct:
					_unlock_door()
				else:
					print("Submission Failed! The mixture exploded! Resetting room...")
					get_tree().reload_current_scene()
		else:
			print("You aren't holding any item to submit!")

func _unlock_door() -> void:
	is_unlocked = true
	interactable.is_interactable = false
	print("Success! The right potions were mixed! Moving to next day.")
	
	puzzle_solved.emit()
	
	if not defer_level_transition:
		SaveManager.complete_level(SaveManager.current_playing_level)
		if SaveManager.current_playing_level < 25:
			SaveManager.current_playing_level += 1
			SceneTransition.transition_to_next_day(SaveManager.current_playing_level)
		else:
			get_tree().change_scene_to_file("res://Menus/level_selection.tscn")

func _start_pulse() -> void:
	if not glow_light:
		return
	var tween = create_tween().set_loops()
	tween.tween_property(glow_light, "energy", 2.5, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(glow_light, "energy", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

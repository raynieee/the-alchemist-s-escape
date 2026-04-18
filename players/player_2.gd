extends CharacterBody2D

@onready var anim = get_node("AnimationPlayer")

@export var action_left := "p2_left"
@export var action_right := "p2_right"
@export var action_jump := "p2_jump"
@export var action_drop := "p2_drop_item"
@export var interact_action := "p2_interact"

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0
# Celeste timing: ~0.1s (6 frames at 60fps) to max speed = 3000.0
@export var ACCELERATION: float = 3000.0
# Celeste timing: ~0.067s (4 frames at 60fps) to stop = 4500.0
@export var FRICTION: float = 4500.0
@export var AIR_ACCELERATION: float = 2000.0
@export var AIR_FRICTION: float = 1000.0

@onready var item_icon: TextureRect = get_node_or_null("Control/UI/ItemIcon")

var held_item: Node2D = null

func _ready() -> void:
	if not item_icon:
		item_icon = get_node_or_null("Control/UI/ItemIcon")
	if item_icon:
		item_icon.mouse_filter = Control.MOUSE_FILTER_STOP
		item_icon.gui_input.connect(_on_item_icon_gui_input)

func _on_item_icon_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		drop_item()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		drop_item()

func pickup_item(item: Node2D) -> bool:
	if held_item != null:
		print("Inventory full!")
		return false
	held_item = item
	
	# Try to find a sprite on the item to use as the icon
	var sprite: Sprite2D = null
	for child in item.get_children():
		if child is Sprite2D:
			sprite = child
			break
			
	if not item_icon:
		item_icon = get_node_or_null("Control/UI/ItemIcon")
		
	if sprite and item_icon:
		item_icon.texture = sprite.texture
		item_icon.custom_minimum_size = Vector2(40, 40)
	
	print("Picked up item!")
	return true

func drop_item():
	if held_item != null:
		get_parent().add_child(held_item)
		held_item.global_position = global_position + Vector2(0, 5)
		# Ensure it's active again
		if held_item.has_node("Interactable"):
			held_item.get_node("Interactable").is_interactable = true
		held_item = null
		
		if item_icon:
			item_icon.texture = null
		
		print("Dropped item!")

func remove_held_item() -> Node2D:
	if held_item == null:
		return null
		
	var item = held_item
	held_item = null
	
	if item_icon:
		item_icon.texture = null
		
	return item

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(action_drop) and held_item:
		drop_item()
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed(action_jump) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim.play("Jump")

	var direction := Input.get_axis(action_left, action_right)
	
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
	
	var current_accel = ACCELERATION if is_on_floor() else AIR_ACCELERATION
	var current_fric = FRICTION if is_on_floor() else AIR_FRICTION

	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, current_accel * delta)
		if velocity.y == 0:
			anim.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, current_fric * delta)
		if velocity.y == 0:
			anim.play("Idle")
	if velocity.y > 0:
			anim.play("Fall")

	move_and_slide()

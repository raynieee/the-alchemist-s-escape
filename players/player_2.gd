extends CharacterBody2D

@onready var anim = get_node("AnimationPlayer")

@export var action_left := "p2_left"
@export var action_right := "p2_right"
@export var action_jump := "p2_jump"
@export var action_drop := "p2_drop_item"
@export var interact_action := "p2_interact"

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

const GROUND_ACCEL = 1000.0
const GROUND_DECEL = 3000.0
const AIR_ACCEL = 800.0
const AIR_DECEL = 2000.0
const TURNAROUND_ACCEL = 5000.0

const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.15

var coyote_timer = 0.0
var jump_buffer_timer = 0.0

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

	# Coyote Time & Jump Buffering timers update
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed(action_jump):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	# Jump trigger check
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		anim.play("Jump")
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	var direction := Input.get_axis(action_left, action_right)
	
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
	
	var accel = GROUND_ACCEL if is_on_floor() else AIR_ACCEL
	var decel = GROUND_DECEL if is_on_floor() else AIR_DECEL

	if direction:
		if sign(direction) != sign(velocity.x) and velocity.x != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, TURNAROUND_ACCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, accel * delta)
		if velocity.y == 0:
			anim.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, decel * delta)
		if velocity.y == 0:
			anim.play("Idle")
	if velocity.y > 0:
		anim.play("Fall")

	move_and_slide()

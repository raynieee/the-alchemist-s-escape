extends Camera2D
class_name CoopCamera2D

@export var player1: CharacterBody2D
@export var player2: CharacterBody2D

@export var min_zoom: float = 0.6
@export var max_zoom: float = 2.0
@export var margin_vector: Vector2 = Vector2(400, 300) # Extra padding so they don't touch the screen edge
@export var smooth_speed: float = 5.0

func _process(delta: float) -> void:
	if not player1 or not player2:
		return
		
	# 1. Position: Find the exact midpoint between the two players
	var mid_point = (player1.global_position + player2.global_position) / 2.0
	
	# Smoothly pan the camera to the midpoint
	global_position = global_position.lerp(mid_point, smooth_speed * delta)
	
	# 2. Zoom: Calculate how far apart they are on both axes
	var distance_x = abs(player1.global_position.x - player2.global_position.x)
	
	# Get the current screen size dynamically
	var screen_size = get_viewport_rect().size
	
	# Calculate the required zoom based ONLY on horizontal distance
	var zoom_x = screen_size.x / max(distance_x + margin_vector.x, 1.0)
	
	# Clamp the horizontal zoom securely between max zoomed out (min_zoom) and fully zoomed in (max_zoom)
	var target_zoom_val = clamp(zoom_x, min_zoom, max_zoom)
	var target_zoom = Vector2(target_zoom_val, target_zoom_val)
	
	# Smoothly apply the zoom
	zoom = zoom.lerp(target_zoom, smooth_speed * delta)

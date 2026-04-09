extends Area2D
class_name FloorButton

@export var target_nodes: Array[NodePath]

var overlapping_bodies_count = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Initial squash state
	$Sprite2D.scale.y = 1.0

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D: # The players are characterbodies
		overlapping_bodies_count += 1
		_update_state()

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		overlapping_bodies_count -= 1
		if overlapping_bodies_count < 0:
			overlapping_bodies_count = 0
		_update_state()

func _update_state() -> void:
	if overlapping_bodies_count > 0:
		# Squashed visual
		$Sprite2D.scale.y = 0.5
		$Sprite2D.position.y = 8 # Move down to keep touching the floor
		
		# Open doors
		for path in target_nodes:
			var node = get_node_or_null(path)
			if node and node.has_method("open"):
				node.open()
	else:
		# Normal visual
		$Sprite2D.scale.y = 1.0
		$Sprite2D.position.y = 0
		
		# Close doors
		for path in target_nodes:
			var node = get_node_or_null(path)
			if node and node.has_method("close"):
				node.close()

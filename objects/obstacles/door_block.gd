extends StaticBody2D
class_name DoorBlock

@export var is_open: bool = false

func _ready() -> void:
	if is_open:
		open()
	else:
		close()

func open() -> void:
	is_open = true
	hide()
	$CollisionShape2D.set_deferred("disabled", true)

func close() -> void:
	is_open = false
	show()
	$CollisionShape2D.set_deferred("disabled", false)

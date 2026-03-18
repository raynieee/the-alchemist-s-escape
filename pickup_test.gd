extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Acorn1

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	if sprite_2d.visible:
		sprite_2d.hide()
		interactable.is_interactable = false
		print("the player picks this up!")

extends StaticBody2D

@export var item_value: int = 1
@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Acorn1

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact(interactor: Node = null):
	if interactor and interactor.has_method("pickup_item"):
		if interactor.pickup_item(self):
			get_parent().remove_child(self)

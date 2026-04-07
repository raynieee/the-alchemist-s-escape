extends StaticBody2D

@export var item_value: float = 1.0
@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Potion

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact(interactor: Node = null):
	if interactor and interactor.has_method("pickup_item"):
		if interactor.pickup_item(self):
			get_parent().remove_child(self)

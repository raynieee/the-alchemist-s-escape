extends SceneTree

func _init():
	var paths = [
		"res://assets/sprites/touch_controls/left.png",
		"res://assets/sprites/touch_controls/right.png",
		"res://assets/sprites/touch_controls/jump.png",
		"res://assets/sprites/touch_controls/interact.png"
	]
	for p in paths:
		var tex = load(p)
		if tex:
			print(p, " size: ", tex.get_size())
	quit()

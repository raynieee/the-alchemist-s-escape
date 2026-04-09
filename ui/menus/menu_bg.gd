extends Node2D

func _process(_delta):
	var tree = get_tree()
	if tree and tree.current_scene:
		var s_name = tree.current_scene.name
		if s_name in ["Main", "LevelSelection", "SaveSelection"]:
			show()
		else:
			hide()

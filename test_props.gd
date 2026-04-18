extends SceneTree

func _init():
	var btn = TouchScreenButton.new()
	var props = btn.get_property_list()
	for p in props:
		if p.name in ["shape", "bitmask", "shape_centered"]:
			print("Has property: ", p.name)
	
	quit()

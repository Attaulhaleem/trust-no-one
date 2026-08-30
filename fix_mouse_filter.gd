extends SceneTree

func _init():
	var ui_scene = load("res://scenes/game/ui_manager.tscn")
	var ui = ui_scene.instantiate()
	
	# Function to recursively set mouse_filter to IGNORE (2)
	var set_ignore = func(node: Control, f: Callable):
		if node:
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE
			for child in node.get_children():
				if child is Control:
					f.call(child, f)
	
	set_ignore.call(ui.get_node("Hud"), set_ignore)
	set_ignore.call(ui.get_node("DescriptionPanel"), set_ignore)
	
	# Ensure GameOverMenu blocks input when visible
	var menu = ui.get_node("GameOverMenu")
	menu.mouse_filter = Control.MOUSE_FILTER_STOP
	var color_rect = menu.get_node("ColorRect")
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var packed_ui = PackedScene.new()
	packed_ui.pack(ui)
	ResourceSaver.save(packed_ui, "res://scenes/game/ui_manager.tscn")
	
	print("Mouse filters fixed!")
	quit()

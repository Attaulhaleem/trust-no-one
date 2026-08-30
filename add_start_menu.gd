extends SceneTree

func _init():
	var ui_scene = load("res://scenes/game/ui_manager.tscn")
	var ui = ui_scene.instantiate()
	
	var game_over = ui.get_node("GameOverMenu")
	var start_menu = game_over.duplicate(7) # duplicate everything
	start_menu.name = "StartMenu"
	ui.add_child(start_menu)
	start_menu.owner = ui
	
	var fix_owner = func(node: Node, f: Callable):
		for child in node.get_children():
			child.owner = ui
			f.call(child, f)
	fix_owner.call(start_menu, fix_owner)
	
	var title = start_menu.get_node("ColorRect/VBoxContainer/TitleLabel")
	title.text = "Trust No One"
	
	var subtitle = start_menu.get_node("ColorRect/VBoxContainer/SubtitleLabel")
	subtitle.text = "Find and eliminate the target."
	
	var start_btn = start_menu.get_node("ColorRect/VBoxContainer/ReplayButton")
	start_btn.name = "StartButton"
	start_btn.text = "Start"
	
	start_menu.visible = true
	game_over.visible = false
	
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var packed = PackedScene.new()
	packed.pack(ui)
	ResourceSaver.save(packed, "res://scenes/game/ui_manager.tscn")
	
	print("Start Menu added!")
	quit()

extends SceneTree

func _init():
	var ui_scene = load("res://scenes/game/ui_manager.tscn")
	var ui = ui_scene.instantiate()
	
	# Set NodePaths for export variables
	ui.set("game_over_menu", ui.get_path_to(ui.get_node("GameOverMenu")))
	ui.set("game_over_title_label", ui.get_path_to(ui.get_node("GameOverMenu/ColorRect/VBoxContainer/TitleLabel")))
	ui.set("game_over_subtitle_label", ui.get_path_to(ui.get_node("GameOverMenu/ColorRect/VBoxContainer/SubtitleLabel")))
	ui.set("replay_button", ui.get_path_to(ui.get_node("GameOverMenu/ColorRect/VBoxContainer/ReplayButton")))
	ui.set("quit_button", ui.get_path_to(ui.get_node("GameOverMenu/ColorRect/VBoxContainer/QuitButton")))
	
	ui.set("start_menu", ui.get_path_to(ui.get_node("StartMenu")))
	ui.set("start_button", ui.get_path_to(ui.get_node("StartMenu/ColorRect/VBoxContainer/StartButton")))
	ui.set("start_quit_button", ui.get_path_to(ui.get_node("StartMenu/ColorRect/VBoxContainer/QuitButton")))
	
	ui.set("hud", ui.get_path_to(ui.get_node("Hud")))
	ui.set("description_panel", ui.get_path_to(ui.get_node("DescriptionPanel")))
	
	var packed = PackedScene.new()
	packed.pack(ui)
	ResourceSaver.save(packed, "res://scenes/game/ui_manager.tscn")
	
	print("UI Manager Nodes mapped successfully!")
	quit()

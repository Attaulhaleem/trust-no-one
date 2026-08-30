extends SceneTree

func _init():
	var font = load("res://assets/fonts/SpecialElite-Regular.ttf")
	if not font:
		print("Failed to load font!")
		quit()
		
	var theme = Theme.new()
	theme.default_font = font
	
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("assets/themes"):
		dir.make_dir_recursive("assets/themes")
		
	var err = ResourceSaver.save(theme, "res://assets/themes/main_theme.tres")
	if err != OK:
		print("Failed to save theme!")
		quit()
		
	ProjectSettings.set_setting("gui/theme/custom", "res://assets/themes/main_theme.tres")
	ProjectSettings.save()
	
	print("Theme created and applied globally.")
	quit()

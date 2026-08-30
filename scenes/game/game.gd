extends Node2D

@export var ui_manager: UIManager
@export var spawner: Spawner

var sfx_casualty = preload("res://assets/sfx/casualty.wav")
var sfx_elimination = preload("res://assets/sfx/elimination.wav")
var sfx_game_lost = preload("res://assets/sfx/game_lost.wav")
var sfx_game_won = preload("res://assets/sfx/game_won.wav")
var sfx_shoot_miss = preload("res://assets/sfx/shoot_miss.wav")

var bgm_menu = preload("res://assets/sfx/menu_theme.wav")
var bgm_gameplay = preload("res://assets/sfx/gameplay_loop.wav")
var bgm_player: AudioStreamPlayer

var total_targets = 0
var killed_targets = 0
var casualties = 0
var max_casualties = 3
var time_left: float = 60.0
var game_over: bool = false

func _ready():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	bgm_player.finished.connect(bgm_player.play)
	add_child(bgm_player)
	_play_bgm(bgm_menu)
	
	get_tree().paused = true
	ui_manager.start_game.connect(_on_start_game)
	# Wait for spawner to finish spawning in its _ready
	call_deferred("_initialize_game")

func _play_bgm(stream: AudioStream):
	if bgm_player.stream == stream and bgm_player.playing:
		return
	bgm_player.stream = stream
	bgm_player.play()

func _on_start_game():
	get_tree().paused = false
	_play_bgm(bgm_gameplay)

func _play_sfx(stream: AudioStream):
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _unhandled_input(event: InputEvent) -> void:
	if game_over or get_tree().paused:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_play_sfx(sfx_shoot_miss)

func _initialize_game():
	var stickmen = get_tree().get_nodes_in_group("stickman")
	
	var target = null
	for s in stickmen:
		if s is Stickman:
			s.died.connect(_on_stickman_died)
			if s.is_special:
				total_targets += 1
				target = s
			
	if target:
		ui_manager.update_witness_statement(target)
		
	ui_manager.update_targets(killed_targets, total_targets)
	ui_manager.update_casualties(casualties, max_casualties)
	ui_manager.update_time(time_left)

func _process(delta: float):
	if game_over:
		return
		
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		_trigger_game_over("lost_time")
		
	ui_manager.update_time(time_left)

func _on_stickman_died(stickman: Stickman):
	if game_over:
		return
		
	if stickman.is_special:
		_play_sfx(sfx_elimination)
		_spawn_floating_text("NEUTRALIZED", stickman.global_position, Color.YELLOW)
		killed_targets += 1
		ui_manager.update_targets(killed_targets, total_targets)
		if killed_targets >= total_targets:
			_trigger_win()
	else:
		_play_sfx(sfx_casualty)
		_spawn_floating_text("CIVILIAN", stickman.global_position, Color.RED)
		casualties += 1
		ui_manager.update_casualties(casualties, max_casualties)
		if casualties >= max_casualties:
			_trigger_game_over("lost_casualties")

func _trigger_game_over(reason: String):
	game_over = true
	_play_sfx(sfx_game_lost)
	_play_bgm(bgm_menu)
	var stickmen = get_tree().get_nodes_in_group("stickman")
	for s in stickmen:
		if s is Stickman:
			s.freeze()
			if not s.is_special and not s.is_dead:
				s.mass_die()
	ui_manager.show_game_over(reason)

func _trigger_win():
	game_over = true
	_play_sfx(sfx_game_won)
	_play_bgm(bgm_menu)
	var stickmen = get_tree().get_nodes_in_group("stickman")
	for s in stickmen:
		if s is Stickman:
			s.freeze()
			if not s.is_dead:
				s.play_dance()
	ui_manager.show_game_over("won")

func _spawn_floating_text(text: String, pos: Vector2, color: Color):
	var node = Node2D.new()
	node.global_position = pos
	node.z_index = 100
	
	var label = Label.new()
	label.text = text
	var settings = LabelSettings.new()
	settings.font_color = color
	settings.font_size = 24
	settings.outline_size = 8
	settings.outline_color = Color.BLACK
	label.label_settings = settings
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.set_anchors_preset(Control.PRESET_CENTER)
	
	node.add_child(label)
	add_child(node)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	node.scale = Vector2.ZERO
	tween.tween_property(node, "scale", Vector2.ONE * 1.5, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "global_position", pos + Vector2(0, -60), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	var fade_tween = create_tween()
	fade_tween.tween_interval(0.5)
	fade_tween.tween_property(node, "modulate:a", 0.0, 0.5)
	fade_tween.tween_callback(node.queue_free)

class_name Spawner
extends Node2D

@export_group("Settings")
@export var scene_to_spawn: PackedScene = null
@export var spawn_count: int = 5
@export var special_count: int = 1:
	set(value):
		special_count = min(value, spawn_count)
@export var spawn_margin: float = 100.0

@export_group("Accessories")
@export var head_accessories: Array[HeadAccessory] = []
@export var eyes_accessories: Array[EyesAccessory] = []
@export var face_accessories: Array[FaceAccessory] = []
@export var neck_accessories: Array[NeckAccessory] = []
@export var chest_accessories: Array[ChestAccessory] = []


var generated_looks = {}

func _ready() -> void:
	spawn_wave()


func spawn_wave() -> void:
	generated_looks.clear()
	var current_screen_size: Vector2 = get_viewport_rect().size

	var positions: Array[Vector2] = []
	for i in range(spawn_count):
		positions.append(Vector2(
			randf_range(spawn_margin, current_screen_size.x - spawn_margin),
			randf_range(spawn_margin, current_screen_size.y - spawn_margin)
		))

	# Spawn targets first so they get priority on unique looks
	var civilian_positions: Array[Vector2] = []
	var all_indexes: Array = range(spawn_count)
	all_indexes.shuffle()
	var special_indexes: Array = all_indexes.slice(0, special_count)

	for i in range(spawn_count):
		if i in special_indexes:
			_spawn_instance(positions[i], true)
		else:
			civilian_positions.append(positions[i])

	for pos in civilian_positions:
		_spawn_instance(pos, false)


func _set_random_sprite_color(sprite: Sprite2D) -> Color:
	var color := Color.BLACK

	if sprite:
		color = Color.from_hsv(randf(), 1.0, 1.0)
		sprite.modulate = color

	return color


func _generate_unique_look(require_all_slots: bool = false) -> Dictionary:
	var look = {}
	var max_attempts = 50
	for attempt in range(max_attempts):
		look = {
			"head": randi() % head_accessories.size() if head_accessories else -1,
			"eyes": randi() % eyes_accessories.size() if eyes_accessories else -1,
			"face": randi() % face_accessories.size() if face_accessories else -1,
			"neck": randi() % neck_accessories.size() if neck_accessories else -1,
			"chest": randi() % chest_accessories.size() if chest_accessories else -1,
		}
		# Targets must have an accessory in every available slot
		if require_all_slots and -1 in look.values():
			continue
		var look_str = str(look.head) + "_" + str(look.eyes) + "_" + str(look.face) + "_" + str(look.neck) + "_" + str(look.chest)
		if not generated_looks.has(look_str):
			generated_looks[look_str] = true
			return look
	return look

func _spawn_instance(spawn_position: Vector2, is_special: bool) -> void:
	if not scene_to_spawn:
		return
	
	var spawnling := scene_to_spawn.instantiate()
	add_child(spawnling)
	spawnling.global_position = spawn_position

	if spawnling is Stickman:
		var stickman: Stickman = spawnling as Stickman
		var look = _generate_unique_look(is_special)
		
		if head_accessories and look.head != -1:
			stickman.head_accessory = head_accessories[look.head]
			_set_random_sprite_color(stickman.head_accessory_sprite)
		if eyes_accessories and look.eyes != -1:
			stickman.eyes_accessory = eyes_accessories[look.eyes]
			_set_random_sprite_color(stickman.eyes_accessory_sprite)
		if face_accessories and look.face != -1:
			stickman.face_accessory = face_accessories[look.face]
			_set_random_sprite_color(stickman.face_accessory_sprite)
		if neck_accessories and look.neck != -1:
			stickman.neck_accessory = neck_accessories[look.neck]
			_set_random_sprite_color(stickman.neck_accessory_sprite)
		if chest_accessories and look.chest != -1:
			stickman.chest_accessory = chest_accessories[look.chest]
			_set_random_sprite_color(stickman.chest_accessory_sprite)
		if is_special:
			stickman.is_special = true

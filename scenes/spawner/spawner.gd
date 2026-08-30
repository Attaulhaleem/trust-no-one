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


func _ready() -> void:
	var current_screen_size: Vector2 = get_viewport_rect().size

	var all_indexes: Array = range(spawn_count)
	all_indexes.shuffle()
	var special_indexes: Array = all_indexes.slice(0, special_count)

	for i in range(spawn_count):
		var random_position := Vector2(
			randf_range(spawn_margin, current_screen_size.x - spawn_margin),
			randf_range(spawn_margin, current_screen_size.y - spawn_margin)
		)
		var is_special: bool = i in special_indexes
		_spawn_instance(random_position, is_special)


func _set_random_sprite_color(sprite: Sprite2D) -> Color:
	var color := Color.BLACK

	if sprite:
		color = Color.from_hsv(randf(), 1.0, 1.0)
		sprite.modulate = Color.from_hsv(randf(), 1.0, 1.0)

	return color


func _spawn_instance(spawn_position: Vector2, is_special: bool) -> void:
	if not scene_to_spawn:
		return
	
	var spawnling := scene_to_spawn.instantiate()
	add_child(spawnling)
	spawnling.global_position = spawn_position

	if spawnling is Stickman:
		var stickman: Stickman = spawnling as Stickman
		if head_accessories:
			stickman.head_accessory = head_accessories[randi() % head_accessories.size()]
			_set_random_sprite_color(stickman.head_accessory_sprite)
		if eyes_accessories:
			stickman.eyes_accessory = eyes_accessories[randi() % eyes_accessories.size()]
			_set_random_sprite_color(stickman.eyes_accessory_sprite)
		if face_accessories:
			stickman.face_accessory = face_accessories[randi() % face_accessories.size()]
			_set_random_sprite_color(stickman.face_accessory_sprite)
		if neck_accessories:
			stickman.neck_accessory = neck_accessories[randi() % neck_accessories.size()]
			_set_random_sprite_color(stickman.neck_accessory_sprite)
		if chest_accessories:
			stickman.chest_accessory = chest_accessories[randi() % chest_accessories.size()]
			_set_random_sprite_color(stickman.chest_accessory_sprite)
		if is_special:
			stickman.is_special = true

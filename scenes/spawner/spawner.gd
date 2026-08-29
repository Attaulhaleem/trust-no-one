class_name Spawner
extends Node2D

@export_group("Settings")
@export var scene_to_spawn: PackedScene = null
@export var spawn_count: int = 5
@export var special_count: int = 1:
	set(value):
		special_count = min(value, spawn_count)
@export var spawn_margin: float = 100.0


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


func _spawn_instance(spawn_position: Vector2, is_special: bool) -> void:
	if not scene_to_spawn:
		return
	
	var spawnling := scene_to_spawn.instantiate()
	add_child(spawnling)
	spawnling.global_position = spawn_position

	if is_special:
		spawnling.is_special = true
		spawnling.modulate = Color.RED

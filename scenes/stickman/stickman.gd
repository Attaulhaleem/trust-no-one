class_name Stickman
extends CharacterBody2D

signal died(stickman: Stickman)

enum AIState {IDLE, WALKING}

const IDLE_ANIMATION := &"idle"
const WALK_HORIZONTAL_ANIMATION := &"walk_horizontal"
const WALK_VERTICAL_ANIMATION := &"walk_vertical"
const DEATH_ANIMATION := &"death"
const DANCE_ANIMATION := &"dance"
const MOVE_LEFT_ACTION := &"move_left"
const MOVE_RIGHT_ACTION := &"move_right"
const MOVE_UP_ACTION := &"move_up"
const MOVE_DOWN_ACTION := &"move_down"

@export_group("Nodes")
@export var animated_sprite: AnimatedSprite2D
@export var bowtie_sprite: Sprite2D
@export var head_accessory_sprite: Sprite2D
@export var eyes_accessory_sprite: Sprite2D
@export var face_accessory_sprite: Sprite2D
@export var neck_accessory_sprite: Sprite2D
@export var chest_accessory_sprite: Sprite2D

@export_group("Resources")
@export var default_cursor: Texture2D = null
@export var zoom_cursor: Texture2D = null
@export var head_accessory: HeadAccessory = null:
	set(value):
		head_accessory = value
		_update_accessory_sprite(head_accessory_sprite, head_accessory)
@export var eyes_accessory: EyesAccessory = null:
	set(value):
		eyes_accessory = value
		_update_accessory_sprite(eyes_accessory_sprite, eyes_accessory)
@export var face_accessory: FaceAccessory = null:
	set(value):
		face_accessory = value
		_update_accessory_sprite(face_accessory_sprite, face_accessory)
@export var neck_accessory: NeckAccessory = null:
	set(value):
		neck_accessory = value
		_update_accessory_sprite(neck_accessory_sprite, neck_accessory)
@export var chest_accessory: ChestAccessory = null:
	set(value):
		chest_accessory = value
		_update_accessory_sprite(chest_accessory_sprite, chest_accessory)

@export_group("Settings")
@export var move_speed: float = 200.0
@export var is_controllable: bool = false

@export_group("AI Settings")
@export var ai_screen_margin: float = 80.0
@export var ai_direction_change_chance: float = 0.02
@export var ai_direction_change_angle: float = 0.3
@export var ai_bounce_angle: float = 0.2
@export var ai_walk_duration_min: float = 3.0
@export var ai_walk_duration_max: float = 9.0
@export var ai_walk_speed_modifier_min: float = 0.3
@export var ai_walk_speed_modifier_max: float = 0.6
@export var ai_idle_duration_min: float = 1.0
@export var ai_idle_duration_max: float = 3.0

var is_special: bool = false # For assassin status
var is_dead: bool = false
var game_over_frozen: bool = false

var ai_current_state: AIState = AIState.IDLE
var ai_state_timer: float = 0.0
var ai_direction: Vector2 = Vector2.ZERO
var ai_speed_modifier: float = 1.0

func _ready() -> void:
	add_to_group("stickman")
	motion_mode = MOTION_MODE_FLOATING
	input_pickable = true
	collision_mask = 0
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	if not is_dead and not game_over_frozen and not get_tree().paused and zoom_cursor:
		Input.set_custom_mouse_cursor(zoom_cursor, Input.CURSOR_ARROW, zoom_cursor.get_size() / 2.0)


func _on_mouse_exited() -> void:
	if default_cursor:
		Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, default_cursor.get_size() / 2.0)


func _physics_process(delta: float) -> void:
	if is_dead or game_over_frozen:
		return

	if is_controllable:
		var direction := Input.get_vector(
			MOVE_LEFT_ACTION,
			MOVE_RIGHT_ACTION,
			MOVE_UP_ACTION,
			MOVE_DOWN_ACTION
		)
		velocity = direction * move_speed
	else:
		_process_ai(delta)
	
	move_and_slide()
	_update_walk_animation()


func _process_ai(delta: float) -> void:
	ai_state_timer -= delta
	
	if ai_state_timer <= 0.0:
		_pick_new_state()
		
	if ai_current_state == AIState.WALKING:
		# Occasional slight direction changes for natural movement
		if randf() < ai_direction_change_chance:
			ai_direction = ai_direction.rotated(
				randf_range(-ai_direction_change_angle, ai_direction_change_angle)
			).normalized()
			
		velocity = ai_direction * (move_speed * ai_speed_modifier)
		
		# Screen boundaries check
		var screen_size = get_viewport_rect().size
		var next_pos = global_position + velocity * delta
		
		var bounced = false
		if next_pos.x < ai_screen_margin and ai_direction.x < 0:
			ai_direction.x *= -1.0
			bounced = true
		elif next_pos.x > screen_size.x - ai_screen_margin and ai_direction.x > 0:
			ai_direction.x *= -1.0
			bounced = true
			
		if next_pos.y < ai_screen_margin and ai_direction.y < 0:
			ai_direction.y *= -1.0
			bounced = true
		elif next_pos.y > screen_size.y - ai_screen_margin and ai_direction.y > 0:
			ai_direction.y *= -1.0
			bounced = true
			
		if bounced:
			# Add a little randomness after a bounce
			ai_direction = ai_direction.rotated(randf_range(-ai_bounce_angle, ai_bounce_angle)).normalized()
			velocity = ai_direction * (move_speed * ai_speed_modifier)
	else:
		velocity = Vector2.ZERO


func _pick_new_state() -> void:
	if ai_current_state == AIState.IDLE:
		ai_current_state = AIState.WALKING
		ai_state_timer = randf_range(ai_walk_duration_min, ai_walk_duration_max)
		ai_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		ai_speed_modifier = randf_range(ai_walk_speed_modifier_min, ai_walk_speed_modifier_max)
	else:
		ai_current_state = AIState.IDLE
		ai_state_timer = randf_range(ai_idle_duration_min, ai_idle_duration_max)
		ai_direction = Vector2.ZERO


func _update_accessory_sprite(sprite: Sprite2D, accessory: Accessory) -> void:
	if accessory and sprite:
		sprite.texture = accessory.texture
		sprite.modulate = accessory.color


func _update_walk_animation() -> void:
	if animated_sprite == null or is_dead:
		return

	if velocity.x != 0.0:
		animated_sprite.flip_h = velocity.x > 0.0

	if velocity == Vector2.ZERO:
		animated_sprite.play(IDLE_ANIMATION)
	elif velocity.x != 0.0:
		animated_sprite.play(WALK_HORIZONTAL_ANIMATION)
	elif velocity.y != 0.0:
		animated_sprite.play(WALK_VERTICAL_ANIMATION)


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if is_dead or game_over_frozen or get_tree().paused:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		_die()


func _die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit(self)
	velocity = Vector2.ZERO
	if default_cursor:
		Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, default_cursor.get_size() / 2.0)
	
	# Create blood particles and add them to the parent so they aren't destroyed when stickman is freed
	var blood := CPUParticles2D.new()
	blood.emitting = false
	blood.amount = 40
	blood.one_shot = true
	blood.explosiveness = 0.95
	blood.lifetime = 0.8
	blood.direction = Vector2(0, -1)
	blood.spread = 60.0
	blood.gravity = Vector2(0, 800)
	blood.initial_velocity_min = 150.0
	blood.initial_velocity_max = 350.0
	blood.scale_amount_min = 4.0
	blood.scale_amount_max = 8.0
	blood.color = Color(0.7, 0.0, 0.0)
	blood.position = global_position
	get_parent().add_child(blood)
	blood.emitting = true
	get_tree().create_timer(blood.lifetime * 1.5).timeout.connect(blood.queue_free)
	
	# Fade out accessories
	_fade_accessories()
	
	if animated_sprite:
		animated_sprite.play(DEATH_ANIMATION)
		animated_sprite.animation_finished.connect(queue_free)
	else:
		queue_free()

func freeze() -> void:
	game_over_frozen = true
	velocity = Vector2.ZERO
	if animated_sprite:
		animated_sprite.play(IDLE_ANIMATION)

func play_dance() -> void:
	if animated_sprite:
		animated_sprite.play(DANCE_ANIMATION)

func mass_die() -> void:
	if animated_sprite:
		animated_sprite.play(DEATH_ANIMATION)
	_fade_accessories()

func _fade_accessories() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	var fade_time := 0.5
	if head_accessory_sprite: tween.tween_property(head_accessory_sprite, "modulate:a", 0.0, fade_time)
	if eyes_accessory_sprite: tween.tween_property(eyes_accessory_sprite, "modulate:a", 0.0, fade_time)
	if face_accessory_sprite: tween.tween_property(face_accessory_sprite, "modulate:a", 0.0, fade_time)
	if neck_accessory_sprite: tween.tween_property(neck_accessory_sprite, "modulate:a", 0.0, fade_time)
	if chest_accessory_sprite: tween.tween_property(chest_accessory_sprite, "modulate:a", 0.0, fade_time)
	if bowtie_sprite: tween.tween_property(bowtie_sprite, "modulate:a", 0.0, fade_time)

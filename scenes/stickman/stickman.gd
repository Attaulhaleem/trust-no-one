extends CharacterBody2D

enum AIState {IDLE, WALKING}

const IDLE_ANIMATION := &"idle"
const WALK_HORIZONTAL_ANIMATION := &"walk_horizontal"
const WALK_VERTICAL_ANIMATION := &"walk_vertical"
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

@export_group("Accessories")
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

@onready var head_accessory_color := _set_random_sprite_color(head_accessory_sprite)
@onready var eyes_accessory_color := _set_random_sprite_color(eyes_accessory_sprite)
@onready var face_accessory_color := _set_random_sprite_color(face_accessory_sprite)
@onready var neck_accessory_color := _set_random_sprite_color(neck_accessory_sprite)
@onready var chest_accessory_color := _set_random_sprite_color(chest_accessory_sprite)

var is_special: bool = false # For assassin status

var ai_current_state: AIState = AIState.IDLE
var ai_state_timer: float = 0.0
var ai_direction: Vector2 = Vector2.ZERO
var ai_speed_modifier: float = 1.0

func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING


func _physics_process(delta: float) -> void:
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
		if next_pos.x < ai_screen_margin or next_pos.x > screen_size.x - ai_screen_margin:
			ai_direction.x *= -1.0
			bounced = true
		if next_pos.y < ai_screen_margin or next_pos.y > screen_size.y - ai_screen_margin:
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


func _set_random_sprite_color(sprite: Sprite2D) -> Color:
	var color := Color.BLACK

	if sprite:
		color = Color.from_hsv(randf(), 1.0, 1.0)
		sprite.modulate = Color.from_hsv(randf(), 1.0, 1.0)

	return color


func _update_accessory_sprite(sprite: Sprite2D, accessory: Accessory) -> void:
	if accessory and sprite:
		sprite.texture = accessory.texture
		sprite.modulate = accessory.color


func _update_accessory_z_index(sprite: Sprite2D, accessory: Accessory) -> void:
	if accessory and sprite:
		sprite.z_index = accessory.back_z_index if velocity.y < 0.0 else 0


func _update_walk_animation() -> void:
	if animated_sprite == null:
		return

	if velocity.x != 0.0:
		animated_sprite.flip_h = velocity.x > 0.0

	# _update_accessory_z_index(head_accessory_sprite, head_accessory)
	# _update_accessory_z_index(eyes_accessory_sprite, eyes_accessory)
	# _update_accessory_z_index(face_accessory_sprite, face_accessory)
	# _update_accessory_z_index(neck_accessory_sprite, neck_accessory)
	# _update_accessory_z_index(chest_accessory_sprite, chest_accessory)

	if velocity == Vector2.ZERO:
		animated_sprite.play(IDLE_ANIMATION)
	elif velocity.x != 0.0:
		animated_sprite.play(WALK_HORIZONTAL_ANIMATION)
	elif velocity.y != 0.0:
		animated_sprite.play(WALK_VERTICAL_ANIMATION)

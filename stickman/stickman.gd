extends CharacterBody2D

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
@export var tie_sprite: Sprite2D
@export var glasses_sprite: Sprite2D
@export var hat_cap_sprite: Sprite2D
@export var hat_top_sprite: Sprite2D
@export var mustache_sprite: Sprite2D

@export_group("Accessories")
@export var bowtie: bool = false:
	set(value):
		bowtie = value
		_apply_accessory_visibility()
@export var tie: bool = false:
	set(value):
		tie = value
		_apply_accessory_visibility()
@export var glasses: bool = false:
	set(value):
		glasses = value
		_apply_accessory_visibility()
@export var hat_cap: bool = false:
	set(value):
		hat_cap = value
		_apply_accessory_visibility()
@export var hat_top: bool = false:
	set(value):
		hat_top = value
		_apply_accessory_visibility()
@export var mustache: bool = false:
	set(value):
		mustache = value
		_apply_accessory_visibility()

@export_group("Settings")
@export var move_speed: float = 200.0
@export var is_player: bool = false


func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	_apply_accessory_visibility()


func _apply_accessory_visibility() -> void:
	if not is_node_ready():
		return
	if bowtie_sprite:
		bowtie_sprite.visible = bowtie
	if tie_sprite:
		tie_sprite.visible = tie
	if glasses_sprite:
		glasses_sprite.visible = glasses
	if hat_cap_sprite:
		hat_cap_sprite.visible = hat_cap
	if hat_top_sprite:
		hat_top_sprite.visible = hat_top
	if mustache_sprite:
		mustache_sprite.visible = mustache


func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	
	if is_player:
		direction = Input.get_vector(MOVE_LEFT_ACTION, MOVE_RIGHT_ACTION, MOVE_UP_ACTION, MOVE_DOWN_ACTION)
	
	velocity = direction * move_speed
	move_and_slide()
	_update_walk_animation()


func _update_walk_animation() -> void:
	if animated_sprite == null:
		return

	if velocity.x != 0.0:
		animated_sprite.flip_h = velocity.x > 0.0

	if velocity == Vector2.ZERO:
		animated_sprite.play(IDLE_ANIMATION)
	elif velocity.x != 0.0:
		animated_sprite.play(WALK_HORIZONTAL_ANIMATION)
	elif velocity.y != 0.0:
		animated_sprite.play(WALK_VERTICAL_ANIMATION)

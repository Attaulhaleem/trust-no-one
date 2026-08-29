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
@export var is_player: bool = false:
	set(value):
		is_player = value
		animated_sprite.modulate = Color.RED if is_player else Color.BLACK

@onready var head_accessory_color := _set_random_sprite_color(head_accessory_sprite)
@onready var eyes_accessory_color := _set_random_sprite_color(eyes_accessory_sprite)
@onready var face_accessory_color := _set_random_sprite_color(face_accessory_sprite)
@onready var neck_accessory_color := _set_random_sprite_color(neck_accessory_sprite)
@onready var chest_accessory_color := _set_random_sprite_color(chest_accessory_sprite)

var is_special: bool = false # For assassin status


func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING


func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	
	if is_player:
		direction = Input.get_vector(MOVE_LEFT_ACTION, MOVE_RIGHT_ACTION, MOVE_UP_ACTION, MOVE_DOWN_ACTION)
	
	velocity = direction * move_speed
	move_and_slide()
	_update_walk_animation()


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

extends CharacterBody2D

const IDLE_ANIMATION := &"idle"
const WALK_ANIMATION := &"walk"

enum Direction {
	LEFT,
	RIGHT,
	UP,
	DOWN
}

const INPUT_ACTION_MAP := {
	Direction.LEFT: &"move_left",
	Direction.RIGHT: &"move_right",
	Direction.UP: &"move_up",
	Direction.DOWN: &"move_down"
}

@export var move_speed: float = 200.0
@export var animated_sprite: AnimatedSprite2D

func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING


func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector(INPUT_ACTION_MAP[Direction.LEFT], INPUT_ACTION_MAP[Direction.RIGHT], INPUT_ACTION_MAP[Direction.UP], INPUT_ACTION_MAP[Direction.DOWN])
	velocity = input_direction * move_speed
	move_and_slide()
	_update_walk_animation()


func _update_walk_animation() -> void:
	if animated_sprite == null:
		return

	if velocity.x != 0.0:
		animated_sprite.flip_h = velocity.x > 0.0

	if velocity == Vector2.ZERO:
		animated_sprite.play(IDLE_ANIMATION)
	elif not animated_sprite.animation == WALK_ANIMATION or not animated_sprite.is_playing():
		animated_sprite.play(WALK_ANIMATION)

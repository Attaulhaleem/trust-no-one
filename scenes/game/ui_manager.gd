class_name UIManager
extends CanvasLayer

@export var targets_label: Label
@export var casualties_label: Label
@export var time_label: Label

@export var head_tex: TextureRect
@export var eyes_tex: TextureRect
@export var face_tex: TextureRect
@export var neck_tex: TextureRect
@export var chest_tex: TextureRect

const GAME_OVER_TITLE := {
	"won": &"You Won!",
	"lost_time": &"You Lost!",
	"lost_casualties": &"You Lost!"
}

const GAME_OVER_SUBTITLE := {
	"won": &"You neutralized the target!",
	"lost_time": &"Too slow! The target escaped.",
	"lost_casualties": &"Stand down! Too many civilian casualties."
}


func update_witness_statement(target: Stickman):
	if target.head_accessory:
		head_tex.texture = target.head_accessory.texture
		head_tex.modulate = target.head_accessory_sprite.modulate
	else:
		head_tex.texture = null
		
	if target.eyes_accessory:
		eyes_tex.texture = target.eyes_accessory.texture
		eyes_tex.modulate = target.eyes_accessory_sprite.modulate
	else:
		eyes_tex.texture = null
		
	if target.face_accessory:
		face_tex.texture = target.face_accessory.texture
		face_tex.modulate = target.face_accessory_sprite.modulate
	else:
		face_tex.texture = null
		
	if target.neck_accessory:
		neck_tex.texture = target.neck_accessory.texture
		neck_tex.modulate = target.neck_accessory_sprite.modulate
	else:
		neck_tex.texture = null
		
	if target.chest_accessory:
		chest_tex.texture = target.chest_accessory.texture
		chest_tex.modulate = target.chest_accessory_sprite.modulate
	else:
		chest_tex.texture = null

func update_targets(killed: int, total: int):
	targets_label.text = "Targets: %d / %d" % [killed, total]

func update_time(time_left: float):
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func update_casualties(killed: int, max_allowed: int):
	casualties_label.text = "Casualties: %d / %d" % [killed, max_allowed]

@onready var game_over_menu = $GameOverMenu
@onready var game_over_title_label = $GameOverMenu/ColorRect/VBoxContainer/TitleLabel
@onready var game_over_subtitle_label = $GameOverMenu/ColorRect/VBoxContainer/SubtitleLabel
@onready var replay_button = $GameOverMenu/ColorRect/VBoxContainer/ReplayButton
@onready var quit_button = $GameOverMenu/ColorRect/VBoxContainer/QuitButton

func _ready():
	replay_button.pressed.connect(func(): get_tree().reload_current_scene())
	quit_button.pressed.connect(func(): get_tree().quit())

func show_game_over(reason: String):
	game_over_title_label.text = GAME_OVER_TITLE[reason]
	game_over_subtitle_label.text = GAME_OVER_SUBTITLE[reason]
	game_over_menu.show()

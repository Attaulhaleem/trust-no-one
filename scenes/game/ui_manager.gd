class_name UIManager
extends CanvasLayer

signal start_game

@export_group("Nodes")
@export var targets_label: Label
@export var casualties_label: Label
@export var time_label: Label
@export var game_over_menu: Control
@export var game_over_title_label: Label
@export var game_over_subtitle_label: Label
@export var replay_button: Button
@export var quit_button: Button
@export var start_menu: Control
@export var start_button: Button
@export var start_quit_button: Button
@export var hud: Control
@export var description_panel: Control

@export_group("Resources")
@export var head_tex: TextureRect
@export var eyes_tex: TextureRect
@export var face_tex: TextureRect
@export var neck_tex: TextureRect
@export var chest_tex: TextureRect
@export var unavailable_icon: Texture2D


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


func _get_cropped_texture(texture: Texture2D) -> Texture2D:
	if not texture: return null
	var image = texture.get_image()
	if not image: return texture
	var used_rect = image.get_used_rect()
	if used_rect.has_area():
		var atlas = AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = used_rect
		return atlas
	return texture

func update_witness_statement(target: Stickman):
	if target.head_accessory:
		head_tex.texture = _get_cropped_texture(target.head_accessory.texture)
		head_tex.modulate = target.head_accessory_sprite.modulate
	else:
		head_tex.texture = unavailable_icon
		head_tex.modulate = Color.WHITE
		
	if target.eyes_accessory:
		eyes_tex.texture = _get_cropped_texture(target.eyes_accessory.texture)
		eyes_tex.modulate = target.eyes_accessory_sprite.modulate
	else:
		eyes_tex.texture = unavailable_icon
		eyes_tex.modulate = Color.WHITE
		
	if target.face_accessory:
		face_tex.texture = _get_cropped_texture(target.face_accessory.texture)
		face_tex.modulate = target.face_accessory_sprite.modulate
	else:
		face_tex.texture = unavailable_icon
		face_tex.modulate = Color.WHITE
		
	if target.neck_accessory:
		neck_tex.texture = _get_cropped_texture(target.neck_accessory.texture)
		neck_tex.modulate = target.neck_accessory_sprite.modulate
	else:
		neck_tex.texture = unavailable_icon
		neck_tex.modulate = Color.WHITE
		
	if target.chest_accessory:
		chest_tex.texture = _get_cropped_texture(target.chest_accessory.texture)
		chest_tex.modulate = target.chest_accessory_sprite.modulate
	else:
		chest_tex.texture = unavailable_icon
		chest_tex.modulate = Color.WHITE


func update_targets(killed: int, total: int, wave: int = 1):
	targets_label.text = "Wave %d | Targets %d/%d" % [wave, killed, total]


func update_time(time_left: float):
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]


func update_casualties(killed: int, max_allowed: int):
	casualties_label.text = "Casualties %d/%d" % [killed, max_allowed]


func _ready():
	Input.set_custom_mouse_cursor(null)
	hud.hide()
	description_panel.hide()
	
	if Engine.has_meta("skip_start") and Engine.get_meta("skip_start"):
		Engine.set_meta("skip_start", false)
		call_deferred("_on_start_pressed")
	
	start_button.pressed.connect(_on_start_pressed)
	start_quit_button.pressed.connect(func(): get_tree().quit())
	
	replay_button.pressed.connect(func():
		Engine.set_meta("skip_start", true)
		get_tree().reload_current_scene()
	)
	quit_button.pressed.connect(func(): get_tree().quit())


func _on_start_pressed():
	start_menu.hide()
	hud.show()
	description_panel.show()
	start_game.emit()


func show_game_over(reason: String, wave: int = 1):
	Input.set_custom_mouse_cursor(null)
	hud.hide()
	description_panel.hide()
	game_over_title_label.text = GAME_OVER_TITLE[reason]
	game_over_subtitle_label.text = GAME_OVER_SUBTITLE.get(reason, "") + "\n\nYou survived " + str(wave - 1) + " waves."
	game_over_menu.show()

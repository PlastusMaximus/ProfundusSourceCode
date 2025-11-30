class_name Lore extends Control

@export var appear_length: int = 15

@onready var color_rect: ColorRect = $ColorRect
@onready var center_container: CenterContainer = $CenterContainer
@onready var intro_text: RichTextLabel = $CenterContainer/IntroText
@onready var second_cave: RichTextLabel = $CenterContainer/SecondCave
@onready var end_text: RichTextLabel = $CenterContainer/EndText
@onready var skip_button: DynamicButton = $SkipButton

func _ready() -> void:
	color_rect.hide()
	for text: RichTextLabel in center_container.get_children():
		text.hide()

func first_lore_bit_tween() -> Tween:
	intro_text.modulate = Color.TRANSPARENT
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var tween: Tween = bit_tween(intro_text)
	tween.tween_property(Input, "mouse_mode", Input.MouseMode.MOUSE_MODE_CAPTURED, 0)
	return tween

func second_lore_bit_tween() -> Tween:
	return bit_tween(second_cave)

func third_lore_bit_tween() -> Tween:
	return bit_tween(end_text)

func bit_tween(text: RichTextLabel) -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(Input, "mouse_mode", Input.MouseMode.MOUSE_MODE_VISIBLE, 0)
	tween.tween_callback(show)
	tween.tween_callback(color_rect.show)
	tween.tween_callback(text.show)
	tween.tween_property(text, "modulate", Color.WHITE, StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_LINEAR)
	tween.tween_interval(appear_length)
	tween.tween_property(text, "modulate", Color.TRANSPARENT, StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(text.hide)
	tween.tween_callback(color_rect.hide)
	tween.tween_callback(hide)
	return tween

func _on_skip_button_pressed() -> void:
	for text: RichTextLabel in center_container.get_children():
		if text.visible:
			color_rect.hide()
			text.hide()
			hide()
			if text  == intro_text:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return

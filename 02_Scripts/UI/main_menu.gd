class_name MainMenu extends Control

@onready var title: RichTextLabel = $Background/CenterContainer/Title
@onready var buttons: GridContainer = $Menu/HBoxContainer/VBoxContainer/Buttons
@onready var new_game: DynamicButton = $"Menu/HBoxContainer/VBoxContainer/Buttons/New Game"
@onready var music: AudioStreamPlayer = $Music
@onready var settings: Settings = GameManagerGlobal.settings

func _ready() -> void:
	appear_tween()

func appear_tween() -> Tween:
	var tween: Tween = create_tween().set_parallel(true)
	var index: int = 0
	for button: DynamicButton in buttons.get_children():
		tween.tween_property(button, "position", Vector2(0, 105 * index), StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_ELASTIC).from(Vector2(0, -600))
		index += 1
	return tween

func _disappear_tween() -> Tween:
	var tween: Tween = create_tween().set_parallel(true)
	for button: DynamicButton in buttons.get_children():
		tween.tween_property(button, "position", Vector2(0, -600), StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_ELASTIC)
	return tween

func _on_new_game_pressed() -> void:
	await _disappear_tween().finished

func _on_settings_pressed() -> void:
	if settings.visible:
		await settings._disappear_tween().finished
		settings.hide()
	else:
		settings.show()
		settings.appear_tween()

func _on_quit_pressed() -> void:
	await _disappear_tween().finished
	GameManagerGlobal.quit_game()

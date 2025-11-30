class_name PauseMenu extends Control

@export_file("*.tscn") var main_menu_world: String = "res://01_Scenes/main_menu_world.tscn"

@onready var title: RichTextLabel = $Background/CenterContainer/Title
@onready var buttons: GridContainer = $Menu/HBoxContainer/VBoxContainer/Buttons
@onready var music: AudioStreamPlayer = $Music
@onready var settings: Settings =  $"../Settings"

func _ready() -> void:
	self_modulate = Color.TRANSPARENT
	modulate = Color.TRANSPARENT
	music.stream_paused = true
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if get_tree().paused:
			GameManagerGlobal.unpause_game()
		else:
			GameManagerGlobal.pause_game()

func pause_tween() -> Tween:
	var tween: Tween = create_tween()
	var pos: Vector2 = position
	tween.tween_property(self, "modulate", Color.WHITE, 0.025).set_trans(Tween.TRANS_CIRC).from(Color.TRANSPARENT)
	tween.tween_property(self, "position", position + Vector2(10,0), 0.025).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "position", position - Vector2(20,0), 0.025).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "position", pos, 0.025).set_trans(Tween.TRANS_CIRC)
	music.stream_paused = false
	return tween

func unpause_tween() -> Tween:
	var tween: Tween = create_tween()
	var pos: Vector2 = position
	tween.tween_property(self, "position", position + Vector2(0,10), 0.025).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "position", position - Vector2(0,20), 0.025).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "position", pos, 0.025).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.025).set_trans(Tween.TRANS_CIRC).from_current()
	music.stream_paused = true
	return tween

func _on_continue_pressed() -> void:
	GameManagerGlobal.unpause_game()

func _on_settings_pressed() -> void:
	if settings.visible:
		await settings._disappear_tween().finished
		settings.hide()
	else:
		settings.appear_tween()

func _on_main_menu_pressed() -> void:
	GameManagerGlobal.unpause_game()
	GameManagerGlobal.load_scene(main_menu_world)

func _on_quit_pressed() -> void:
	GameManagerGlobal.unpause_game()
	GameManagerGlobal.quit_game()

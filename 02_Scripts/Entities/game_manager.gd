class_name GameManager extends Node

###Commands the StatManager to change the game state to the new state
#signal change_state(new_state: StatManager.States)
##Commands the StatManager to change the game language to the new language
signal change_language(new_language: StatManager.Languages)
##Informs every listener that the current game language has been changed
signal language_changed()

@onready var ui_layer: CanvasLayer = $UI_Layer
@onready var game_ui: GameUI = $UI_Layer/GameUI
@onready var tutorial: Tutorial = $UI_Layer/Tutorial
@onready var lore: Lore = $UI_Layer/Lore
@onready var pause_menu: PauseMenu = $UI_Layer/PauseMenu
@onready var settings: Settings = $UI_Layer/Settings
@onready var music_manager: MusicManager = $UI_Layer/MusicManager
@onready var load_manager: LoadManager = $LoadManager

func _ready() -> void:
	_hide_ui()
	_connect_signals()

##Connects the required signals to their respective functions
func _connect_signals() -> void:
	#change_state.connect(_on_game_state_changed)
	change_language.connect(_on_game_language_changed)

##Hides every UI element and then quits the game
func quit_game() -> void:
	_hide_ui()
	load_manager.quit_game()

##Hides every UI element and then loads the selected scene
func load_scene(scene_path: String) -> void:
	_hide_ui()
	load_manager.load_scene(scene_path)

##Hides only the settings (dialogue and microgame boxes have to stay visible) and then pauses the game
func pause_game() ->  void:
	settings.hide()
	pause_menu.show()
	await pause_menu.pause_tween().finished
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

##Hides only the settings (dialogue and microgame boxes have to stay visible) and then unpauses the game
func unpause_game() -> void:
	settings.hide()
	await pause_menu.unpause_tween().finished
	pause_menu.hide()
	get_tree().paused = false
	if get_tree().get_first_node_in_group("Player") is WalkPlayer:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

##Hides all UI elements managed by the GameManager.
func _hide_ui() -> void:
	for child: Node in ui_layer.get_children():
		if child is Control:
			child.hide()

###Commands the StatManager to change the game state to the new state
#func _on_game_state_changed(new_state: StatManager.States) -> void:
	#StatManagerGlobal.change_game_state(new_state)

##Commands the StatManager to change the game language to the new language
func _on_game_language_changed(new_language: StatManager.Languages) -> void:
	StatManagerGlobal.change_game_language(new_language)
	language_changed.emit()

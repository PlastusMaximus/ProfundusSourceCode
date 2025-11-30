class_name Credits extends Node3D

const MAIN_MENU: String = "res://01_Scenes/main_menu_world.tscn"


func _ready() -> void:
	await GameManagerGlobal.lore.third_lore_bit_tween().finished


func _on_main_menu_button_pressed() -> void:
	GameManagerGlobal.load_scene(MAIN_MENU)


func _on_quit_button_pressed() -> void:
	GameManagerGlobal.quit_game()

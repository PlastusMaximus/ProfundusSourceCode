class_name Level extends Node3D

@export var level: int

func _ready() -> void:
	GameManagerGlobal.music_manager.level_started()
	GameManagerGlobal.game_ui.show()
	GameManagerGlobal.tutorial.show()
	
	match level:
		1:
			await GameManagerGlobal.lore.first_lore_bit_tween().finished
			GameManagerGlobal.tutorial.show_tween(GameManagerGlobal.tutorial.flash)
		4:
			await GameManagerGlobal.lore.second_lore_bit_tween().finished

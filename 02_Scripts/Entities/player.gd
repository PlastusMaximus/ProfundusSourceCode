class_name Player extends CharacterBody3D

var touching_portal: bool = false
var portal: Portal

func _ready() -> void:
	GameManagerGlobal.game_ui.set_player(self)

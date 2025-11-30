class_name WalkLevel extends Level

func _ready() -> void:
	super._ready()
	GameManagerGlobal.game_ui.hide_ui_for_walking()

func _on_crouch_tutorial_area_body_entered(body: Node3D) -> void:
	if body is Player:
		GameManagerGlobal.tutorial.show_tween(GameManagerGlobal.tutorial.crouch)

func _on_crouch_tutorial_area_body_exited(body: Node3D) -> void:
	if body is Player:
		GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.crouch)

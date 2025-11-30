class_name MainMenuWorld extends Node3D

@export_file("*.tscn") var first_scene: String = "res://01_Scenes/Level/first_cave.tscn"

@onready var camera: Camera3D = $Camera
@onready var quickflash: QuickFlash = $Camera/Quickflash
@onready var main_menu: MainMenu = $MainMenu
@onready var dirt: StaticBody3D = $dirt

var cam_hover: Tween

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	main_menu.new_game.pressed.connect(_on_new_game_pressed)
	cam_hover = cam_hover_tween()

func _on_new_game_pressed() -> void:
	cam_hover.stop()
	dirt.interact()
	quickflash.flash.emit()
	await first_rotation_tween().finished
	await move_cam_tween().finished
	var tween: Tween = create_tween()
	tween.tween_property(camera, "position", Vector3(4.918, -3, -3.821), StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_EXPO)
	GameManagerGlobal.load_scene(first_scene)

func first_rotation_tween() -> Tween:
	var first_rotation: Tween = create_tween()
	first_rotation.tween_property(camera, "rotation_degrees", Vector3(0, 30, 0), StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_CUBIC).from(Vector3.ZERO)
	return first_rotation

func move_cam_tween() -> Tween:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(camera, "position", Vector3(4.918, .079, -3.821), StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_BACK)
	tween.tween_property(camera, "rotation_degrees", Vector3(-90, 30, 0), StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_CUBIC)
	return tween

func cam_hover_tween() -> Tween:
	var tween: Tween = create_tween()
	var cam_position = camera.position
	tween.tween_property(camera, "position", cam_position + Vector3(0,.1,0), StatManagerGlobal.ui_speed * 5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(camera, "position", cam_position - Vector3(0,.1,0), StatManagerGlobal.ui_speed * 5).set_trans(Tween.TRANS_LINEAR)
	tween.set_loops(69)
	return tween

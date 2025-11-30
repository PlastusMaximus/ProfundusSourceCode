class_name Portal extends Node3D

@export var time_to_break: float = 10
@export var tween_speed: float = 1
@export var deactivated: bool = false
@export var last_portal: bool = false

@onready var portal_main: MeshInstance3D = $Portal/Armature/Skeleton3D/PortalMain
@onready var activated_shape: CollisionShape3D = $ActivatedShape
@onready var deactivated_shape: CollisionPolygon3D = $DeactivatedShape
@onready var deactivate: AudioStreamPlayer = $Deactivate

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if deactivated:
		deactivate_tween()
	deactivate.pitch_scale = randf_range(.9,1.1)

func break_portal(amount: float) -> void:
	time_to_break -= amount
	if time_to_break <= 0:
		deactivate_tween()

func recover_portal(amount: float) -> void:
	time_to_break += amount
	if time_to_break >= GameManagerGlobal.game_ui.portal_progress.max_value:
		time_to_break = GameManagerGlobal.game_ui.portal_progress.max_value

func activate_tween() -> Tween:
	var tween: Tween = get_tree().create_tween().set_parallel()
	tween.tween_property(portal_main, "transparency", 0, tween_speed).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(activated_shape, "disabled", false, 0)
	tween.tween_property(deactivated_shape, "disabled", true, 0)
	return tween

func deactivate_tween() -> Tween:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_callback(deactivate.play)
	tween.tween_property(portal_main, "transparency", 1, tween_speed).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(activated_shape, "disabled", true, 0)
	tween.tween_property(deactivated_shape, "disabled", true, 0)
	tween.tween_property(self, "deactivated", true, 0)
	tween.tween_property(player, "touching_portal", false, 0)
	tween.tween_property(player, "portal", null, 0)
	tween.tween_subtween(GameManagerGlobal.game_ui.hide_tween(GameManagerGlobal.game_ui.portal_progress))
	return tween

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		if not deactivated:
			body.touching_portal = true
			body.portal = self
			GameManagerGlobal.game_ui.portal_progress.max_value = time_to_break
			GameManagerGlobal.game_ui.show_tween(GameManagerGlobal.game_ui.portal_progress)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		body.touching_portal = false
		body.portal = self

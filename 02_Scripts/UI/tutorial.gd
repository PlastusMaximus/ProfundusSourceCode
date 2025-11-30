class_name Tutorial extends Control

@onready var look_back: Panel = $LookBackPanel
@onready var cannot_look_back: Panel = $CannotLookBack
@onready var look_forward: Panel = $LookForwardPanel
@onready var flash: Panel = $FlashPanel
@onready var drag: Panel = $DragPanel
@onready var crouch: Panel = $CrouchPanel

func _ready() -> void:
	for child: Panel in get_children():
		child.hide()
		child.modulate = Color.TRANSPARENT

func show_tween(panel: Panel) -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.tween_callback(panel.show)
	tween.tween_property(panel, "modulate", Color.WHITE, StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_QUAD)
	return tween

func hide_tween(panel: Panel) -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(panel, "modulate", Color.TRANSPARENT, StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(panel.hide)
	return tween

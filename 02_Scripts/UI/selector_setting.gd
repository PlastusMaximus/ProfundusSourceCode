class_name SelectorSetting extends Panel

signal index_changed(index: int)

@export var setting_name: String

@onready var info: Label = $Container/Info
@onready var option_button: OptionButton = $Container/OptionButton

func _ready() -> void:
	info.text = setting_name + ":"
	mouse_entered.connect(mark_tween)
	mouse_exited.connect(unmark_tween)
	option_button.item_selected.connect(_on_option_button_item_selected)

func mark_tween() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate", Color(1,1,0.5,1), 0.1).set_trans(Tween.TRANS_CUBIC)

func unmark_tween() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.1).set_trans(Tween.TRANS_CUBIC)

func _on_drag_started() -> void:
	mark_tween()

func _on_drag_ended(_value_changed: float) -> void:
	unmark_tween()

func _on_option_button_item_selected(index: int) -> void:
	index_changed.emit(index)

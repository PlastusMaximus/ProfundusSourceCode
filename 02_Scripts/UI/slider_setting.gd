class_name SliderSetting extends Panel

signal value_changed(value: float)

@export var setting_name: String

@onready var info: Label = $Container/Info
@onready var slider: HSlider = $Container/Slider
@onready var stat: Label = $Container/Stat

func _ready() -> void:
	info.text = setting_name + ":"
	stat.text = str(int(slider.value))
	slider.value_changed.connect(_on_slider_value_changed)
	mouse_entered.connect(mark_tween)
	mouse_exited.connect(unmark_tween)
	slider.drag_started.connect(_on_drag_started)
	slider.drag_ended.connect(_on_drag_ended)

func _on_slider_value_changed(value: float) -> void:
	stat.text = str(int(value)) + "%"
	value_changed.emit(value)

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

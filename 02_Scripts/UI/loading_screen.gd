class_name LoadingScreen extends Control

signal loading_screen_has_full_coverage()

@onready var progress_bar: ProgressBar = $UI/Background/ProgressBar
@onready var animations: AnimationPlayer = $Animations

func _ready() -> void:
	animations.play("appear")
	animations.queue("loading")

func _update_progress_bar(new_value: float) -> void:
	progress_bar.set_value_no_signal(new_value * 100)

func _start_outro_animation() -> void:
	self.animations.play("disappear")
	await animations.animation_finished
	self.queue_free()

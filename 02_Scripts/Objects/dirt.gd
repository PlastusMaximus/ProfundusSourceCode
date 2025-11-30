class_name Dirt extends StaticBody3D

@onready var mesh := $JunkPile01
@onready var sfx: AudioStreamPlayer = $Dig


func interact() -> void:
		sfx.play()
		hide()
		await sfx.finished
		queue_free()

extends Area3D

@export_file("*.tscn") var next_area: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player or body is CrawlPlayer:
		GameManagerGlobal.load_scene(next_area)

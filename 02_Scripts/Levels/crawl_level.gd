class_name CrawlLevel extends Level

@onready var areas: Node3D = $areas

func _ready() -> void:
	super._ready()
	_connect_tight_areas()

func _connect_tight_areas() -> void:
	for child: Area3D in areas.get_children():
		child.body_entered.connect(_on_tight_area_body_entered)
		child.body_exited.connect(_on_tight_area_body_exited)

func _on_tight_area_body_entered(body: Node3D) -> void:
	if body is CrawlPlayer:
		body._on_tight_area_entered()

func _on_tight_area_body_exited(body: Node3D) -> void:
	if body is CrawlPlayer:
		body._on_tight_area_exited()

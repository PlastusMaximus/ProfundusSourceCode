class_name MusicManager extends Control

@onready var level_1: AudioStreamPlayer = $Level1
@onready var level_2: AudioStreamPlayer = $Level2
@onready var level_3: AudioStreamPlayer = $Level3

var weight: float = .25

func level_started() -> void:
	level_2.volume_linear = 0
	level_3.volume_linear = 0
	
	level_1.play()
	level_2.play()
	level_3.play()

func stop() -> void:
	level_1.stop()
	level_2.stop()
	level_3.stop()

func _process(_delta: float) -> void:
	if not get_tree().get_nodes_in_group("Creature").is_empty():
		var creature: Creature = get_tree().get_first_node_in_group("Creature")
		set_level(creature.state)
	else:
		set_level(Creature.States.GONE)

func set_level(level: Creature.States) -> void:
	match level:
		Creature.States.GONE:
			level_1.volume_linear = lerp(level_1.volume_linear, 1.0, weight)
			level_2.volume_linear = lerp(level_2.volume_linear, 0.0, weight)
			level_3.volume_linear = lerp(level_3.volume_linear, 0.0, weight)
		Creature.States.IN_TUNNEL:
			level_1.volume_linear = lerp(level_1.volume_linear, 0.0, weight)
			level_2.volume_linear = lerp(level_2.volume_linear, 1.0, weight)
			level_3.volume_linear = lerp(level_3.volume_linear, 0.0, weight)
		Creature.States.NEAR_PLAYER:
			level_1.volume_linear = lerp(level_1.volume_linear, 0.0, weight)
			level_2.volume_linear = lerp(level_2.volume_linear, 0.0, weight)
			level_3.volume_linear = lerp(level_3.volume_linear, 1.0, weight)

class_name QuickFlash extends SpotLight3D

signal flash()
signal failed_flash()

@export var can_flash: bool = true

@onready var reload: AudioStreamPlayer = $Reload
@onready var zack: AudioStreamPlayer = $Zack
@onready var fail: AudioStreamPlayer = $Fail
@onready var multiple_fails: AudioStreamPlayer = $MultipleFails

@export_category("Cooldown")
## Dauer des Cooldowns nach dem Drücken in Sekunden
@export var cooldown_time: float = 4.0  
##Die Länge des Blitz Effekts
@export var duration: float = 0.2
## Cooldown-Flag, um die Eingabe zu blockieren
var is_on_cooldown: bool = false  
## Variable zur Steuerung, ob das Licht an oder aus ist
var is_light_on: bool = false

var player: CharacterBody3D
var creature: Creature
var initial_cooldown_time: float

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	creature = get_tree().get_first_node_in_group("Creature")
	flash.connect(_on_flash)
	failed_flash.connect(_on_failed_flash)
	initial_cooldown_time = cooldown_time

func _process(_delta: float) -> void:
	handle_light()

func _on_flash() -> void:
	# Starte den Cooldown
		is_on_cooldown = true
		await get_tree().create_timer(0.5).timeout
		# Schalte das Licht ein
		zack.pitch_scale = randf_range(.9, 1.1)
		zack.play(0.15)
		reload.pitch_scale = randf_range(.9, 1.1)
		reload.play(0.5)
		is_light_on = true
		light_energy = 16  # Setze die Lichtenergie auf das Maximum
		if creature != null:
			creature.eye_l.hide()
			creature.eye_r.hide()
		GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.flash)
		if player is CrawlPlayer and player.first_look_forward:
			GameManagerGlobal.tutorial.show_tween(GameManagerGlobal.tutorial.look_forward)
			player.first_look_forward = false
		start_cooldown()

func _on_failed_flash() -> void:
	fail.pitch_scale = randf_range(.9, 1.1)
	fail.play()
	is_on_cooldown = true
	reload.pitch_scale = randf_range(.9, 1.1)
	reload.play(0.5)
	start_cooldown()

func handle_light() -> void:
	# Überprüfe, ob das Licht an ist
	if is_light_on:
		# Logik, um das Licht während der Zeit des Cooldowns an zu lassen
		light_energy = 16  # Licht bleibt gleich stark während des Cooldowns

# Coroutine-Funktion für den Cooldown
func start_cooldown() -> void:
	# Warte für die Cooldown-Zeit
	await get_tree().create_timer(duration).timeout
	
	# Nach dem Cooldown: Licht ausschalten und Cooldown-Status zurücksetzen
	is_light_on = false
	light_energy = 0  # Setze die Lichtenergie auf 0, um das Licht sofort auszuschalten
	if creature != null:
		creature.eye_l.show()
		creature.eye_r.show()
	var timer: SceneTreeTimer = get_tree().create_timer(cooldown_time)
	GameManagerGlobal.game_ui.recharge_flash(timer)
	await timer.timeout
	# Cooldown beenden
	is_on_cooldown = false

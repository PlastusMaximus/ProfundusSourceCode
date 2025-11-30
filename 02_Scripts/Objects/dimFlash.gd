class_name DimFlash extends SpotLight3D

signal dim()
signal dimmed()

@export_category("Cooldown")
## Dauer des Cooldowns nach dem Drücken in Sekunden
@export var cooldown_time: float = 4.2  
## Die Zeit, die benötigt wird, um die Lichtenergie von 16 auf 0 zu reduzieren (in Sekunden)
@export var duration: float = 1.2

## Cooldown-Flag, um die Eingabe zu blockieren
var is_on_cooldown: bool = false
## Zeit, die seit dem Start des Abblendens vergangen ist
var time_passed: float = 0.0
## Flag, um den Abblendprozess zu steuern
var is_dimming: bool = false

func _ready() -> void:
	dim.connect(_on_dim)

func _process(delta: float) -> void:
	handle_dimming(delta)

func _on_dim() -> void:
		await get_tree().create_timer(0.5).timeout
		# Wenn die Taste gedrückt wird, starte den Abblendprozess
		if not is_dimming:
			is_dimming = true
			time_passed = 0.0  # Zurücksetzen der Zeit für die Berechnung
			# Starte den Cooldown nach dem Drücken
			is_on_cooldown = true
			# Starte den Cooldown parallel, ohne den Abblendprozess zu stören
			start_cooldown()

func handle_dimming(delta: float) -> void:
	# Überprüfen, ob der Abblendprozess aktiv ist
	if is_dimming:
		# Erhöhen der verstrichenen Zeit
		time_passed += delta
		# Berechne den Fortschritt des Abblendens (zwischen 0 und 1)
		var progress: float = time_passed / duration
		# Lineare Interpolation der Lichtenergie von 16 auf 0
		light_energy = lerp(3.0, 0.0, progress)
		
		# Optional: Begrenze die Lichtenergie auf den Bereich zwischen 0 und 16
		light_energy = clamp(light_energy, 0.0, 16.0)
		
		# Beende das Abblenden, wenn der Fortschritt 1 oder mehr erreicht
		if progress >= 1.0:
			is_dimming = false
			dimmed.emit()
			light_energy = 0.0  # Endgültige Lichtenergie auf 0 setzen

# Coroutine-Funktion für den Cooldown
func start_cooldown() -> void:
	# Starte einen Timer für den Cooldown, ohne den Prozess zu blockieren
	await get_tree().create_timer(cooldown_time).timeout
	# Cooldown beenden
	is_on_cooldown = false

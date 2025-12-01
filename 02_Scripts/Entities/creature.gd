class_name Creature extends CharacterBody3D

@export var state: States = States.GONE
@export var state_switch_min: float = 8
@export var state_switch_max: float = 12
@export_range(0, 1000) var chance_for_sfx: float = 1
@export_range(0, 100) var movement_probability: float = 69
@export var jumpscare_length: float = 1

@onready var skeleton_3d: Skeleton3D = $Skeleton3D
@onready var state_switch: Timer = $StateSwitch
@onready var eye_l: MeshInstance3D = $Skeleton3D/EyeL
@onready var eye_r: MeshInstance3D = $Skeleton3D/EyeR
@onready var breath_1: AudioStreamPlayer3D = $Breath1
@onready var breath_2: AudioStreamPlayer3D = $Breath2
@onready var crawling: AudioStreamPlayer3D = $Crawling
@onready var jumpscare: AudioStreamPlayer3D = $Jumpscare
@onready var jumpscare_lighting: OmniLight3D = $JumpscareLighting


enum States {
	GONE,
	IN_TUNNEL,
	NEAR_PLAYER,
	JUMPSCARING
}

var state_bone_positions: Dictionary[String, Dictionary] = {"Level1": {"Neck": Vector3()}}

var player: CrawlPlayer
var first_threat: bool = true

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player != null:
		player.quickflash.flash.connect(_on_player_flash)
	state_switch.wait_time = randf_range(state_switch_min, state_switch_max)
	state_switch.start()
	#left eye color reset
	eye_l.get_surface_override_material(0).albedo_color = Color.WHITE
	eye_l.get_surface_override_material(0).emission = Color.WHITE
	#right eye color reset
	eye_r.get_surface_override_material(0).albedo_color = Color.WHITE
	eye_r.get_surface_override_material(0).emission = Color.WHITE

func _input(event: InputEvent) -> void:
	##DEBUG
	if event.is_action("Move_Left"):
		jumpscare_tween()

func _process(_delta: float) -> void:
	handle_position()
	handle_random_sounds()

func handle_position() -> void:
	if not player.in_tight_area:
		match state:
			States.GONE:
				global_position = player.global_position + Vector3(0,0,30)
			States.IN_TUNNEL:
				global_position = player.global_position + Vector3(0,0,7)
			States.NEAR_PLAYER:
				global_position = player.global_position + Vector3(0,0,5)
			States.JUMPSCARING:
				pass

func handle_random_sounds() -> void:
	var lucky_number: float = randf_range(0,1000)
	if lucky_number < chance_for_sfx:
		var lucky_second: int = randi_range(0,2)
		match lucky_second:
			0:
				if not breath_1.playing and not breath_2.playing:
					breath_1.play()
			1:
				if not breath_1.playing and not breath_2.playing:
					breath_2.play()
			2:
				if not crawling.playing:
					crawling.play()

func prepare_jumpscare_tween() -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.tween_callback(GameManagerGlobal.music_manager.stop)
	#ui stuff
	tween.tween_callback(GameManagerGlobal._hide_ui)
	tween.tween_callback(GameManagerGlobal.game_ui.hide_ui_for_walking)
	
	#disabling flash
	tween.tween_property(player, "flash_fail_chance", 100, 0)
	#flashlight stuff
	tween.tween_property(player.flashlight, "light_color", Color.CRIMSON,.1).set_trans(Tween.TRANS_EXPO)
	
	if not player.in_tight_area:
		tween.tween_property(player.flashlight, "light_energy", 0,.1).set_trans(Tween.TRANS_SPRING)
		tween.tween_callback(player.flashlight.hide)
		if player.can_crawl:
			#flashlight off
			tween.tween_property(jumpscare_lighting, "light_energy", 32, randf_range(.5,2)).set_trans(Tween.TRANS_SPRING)
			tween.tween_property(jumpscare_lighting, "light_energy", 0, randf_range(.5,2)).set_trans(Tween.TRANS_SPRING)
			#turning player around
			tween.tween_subtween(player.turn_back_tween())
			#disabling ui again
			tween.tween_callback(GameManagerGlobal.game_ui.hide_ui_for_walking)
		#monster moving away
		tween.tween_subtween(scare_away_tween())
		#monster moving again
		tween.tween_property(self, "global_position", player.global_position+Vector3(0,0,randi_range(5,20)),randf_range(.5,3)).set_trans(Tween.TRANS_ELASTIC)
	else:
		tween.tween_property(jumpscare_lighting, "light_energy", 32, randf_range(.5,2)).set_trans(Tween.TRANS_SPRING)
		#tween.tween_property(jumpscare_lighting, "light_energy", 12, randf_range(.5,2)).set_trans(Tween.TRANS_SPRING)
		tween.tween_callback(hide)
	#player shaking
	var duration = randf_range(1,10)
	tween.tween_subtween(player.shiver_tween(duration, duration * 10))
	return tween

func scare_away_tween() -> Tween:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_callback(player.quickflash.multiple_fails.play)
	#monster moving away
	tween.tween_property(self, "global_position", player.global_position+Vector3(0,0,randi_range(5,10)),randf_range(.5,3)).set_trans(Tween.TRANS_EXPO)
	return tween

func jumpscare_tween() -> Tween:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	#scream
	tween.tween_callback(jumpscare.play)
	#Monster lighting up
	tween.tween_property(jumpscare_lighting, "light_energy", 10, jumpscare_length).set_trans(Tween.TRANS_SPRING)
	#Monster moving
	tween.tween_property(self, "global_position", player.back_cam.global_position+Vector3(0,0,3.25), jumpscare_length/2).set_trans(Tween.TRANS_QUAD)
	#Left eye
	tween.tween_property(eye_l, "scale", Vector3(4,4,4), jumpscare_length).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(eye_l.get_surface_override_material(0), "emission", Color.RED, jumpscare_length).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(eye_l.get_surface_override_material(0), "albedo_color", Color.RED, jumpscare_length).set_trans(Tween.TRANS_BOUNCE)
	#Right eye
	tween.tween_property(eye_r, "scale", Vector3(4,4,4), jumpscare_length).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(eye_r.get_surface_override_material(0), "emission", Color.RED, jumpscare_length).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(eye_r.get_surface_override_material(0), "albedo_color", Color.RED, jumpscare_length).set_trans(Tween.TRANS_BOUNCE)
	#Player shaking
	tween.tween_subtween(player.die_tween())
	return tween

func tight_area_jumpscare_tween() -> Tween:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_callback(jumpscare.play)
	tween.tween_property(player, "global_position", Vector3(0, 2.341, 21.505), 1).set_trans(Tween.TRANS_EXPO)
	tween.tween_subtween(player.die_tween())
	return tween

func _on_player_flash() -> void:
	if state == States.NEAR_PLAYER:
			await player.dim_flash.dimmed
			var tween = get_tree().create_tween()
			tween.tween_property(self, "global_position", player.global_position + Vector3(0,0,30), 1).set_trans(Tween.TRANS_EXPO)
			##Hier könnte ein Bug wegen dem Timing entstehen 
			await tween.finished
			state = States.GONE

func _on_state_switch_timeout() -> void:
	if state < States.NEAR_PLAYER and not player.dim_flash.is_dimming:
		var lucky_number: int = randi_range(0,100)
		if lucky_number < movement_probability:
			state += 1
			if state == States.NEAR_PLAYER:
				if first_threat:
					if player.can_crawl:
						await GameManagerGlobal.tutorial.show_tween(GameManagerGlobal.tutorial.look_back).finished
					first_threat = false
		state_switch.wait_time = randf_range(state_switch_min, state_switch_max)
	elif state == States.NEAR_PLAYER:
		state = States.JUMPSCARING
		await prepare_jumpscare_tween().finished
		if player.in_tight_area:
			await tight_area_jumpscare_tween().finished
		else:
			await jumpscare_tween().finished
		GameManagerGlobal.load_scene(get_tree().current_scene.scene_file_path)

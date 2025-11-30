class_name CrawlPlayer extends Player

## mouse to speed conversion strength
const DRAG_TO_FORCE := 0.005
## how fast u brake
const DAMPING := 10.0     

const REGULAR_CURSOR: CompressedTexture2D = preload("uid://ccg66je0meiso")
const GRAB_CURSOR: CompressedTexture2D = preload("uid://degn6ri0cbf4g")

@export_range(0, 100) var flash_fail_chance: float = 5.0

@onready var neck: Node3D = $Neck
@onready var head: Node3D = $Neck/Head
@onready var eyes: Node3D = $Neck/Head/Eyes


@onready var actual_cam: Camera3D = $Neck/Head/Eyes/ActualCam
@onready var front_cam: Camera3D = $FrontCam
@onready var back_cam: Camera3D = $BackCam
@onready var dim_flash: DimFlash = $BackCam/dimFlash
@onready var quickflash: QuickFlash = $BackCam/Quickflash
@onready var flashlight: SpotLight3D = $FrontCam/flashlight
@onready var crosshair: Control = $Crosshair
@onready var crawl: AudioStreamPlayer = $Crawl


var can_crawl: bool = true
var drag_power: float = 0.0
var dragging: bool = false

var creature: Creature

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	creature = get_tree().get_first_node_in_group("Creature")
	GameManagerGlobal.game_ui.set_player(self)
	quickflash.can_flash = false
	crawl.play()
	crawl.stream_paused = true
	GameManagerGlobal.game_ui.show_tween(GameManagerGlobal.game_ui.look_backward_panel)
	GameManagerGlobal.tutorial.show_tween(GameManagerGlobal.tutorial.drag)

func _input(event: InputEvent) -> void:
	# Überprüfen, ob die linke Maustaste gedrückt ist und kein Cooldown aktiv ist
	if event.is_action("Flash") and not quickflash.is_on_cooldown and quickflash.can_flash:
		var lucky_number: float = randf_range(0,100)
		if lucky_number < flash_fail_chance:
			quickflash.failed_flash.emit()
		else:
			quickflash.flash.emit()
			dim_flash.dim.emit()

func turn_back_tween() -> Tween:
	var tween: Tween = create_tween()
	tween.tween_callback(actual_cam.reparent.bind(self))
	tween.tween_callback(flashlight.reparent.bind(front_cam))
	tween.tween_property(Input, "mouse_mode", Input.MOUSE_MODE_CAPTURED, 0)
	tween.tween_subtween(move_cam_backward())
	tween.tween_subtween(GameManagerGlobal.game_ui.let_stuff_appear_on_the_back())
	return tween

func turn_forward_tween() -> Tween:
	var tween: Tween = create_tween()
	tween.tween_property(Input, "mouse_mode", Input.MOUSE_MODE_CAPTURED, 0)
	tween.tween_subtween(move_cam_forward())
	tween.tween_callback(actual_cam.reparent.bind(eyes))
	tween.tween_callback(flashlight.reparent.bind(actual_cam))
	tween.tween_subtween(GameManagerGlobal.game_ui.let_stuff_appear_front())
	return tween

func move_cam_backward() -> Tween:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(Input, "mouse_mode", Input.MOUSE_MODE_CAPTURED, 0)
	tween.tween_property(actual_cam, "rotation_degrees", back_cam.rotation_degrees, 1).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(actual_cam, "position", back_cam.position, 1).set_trans(Tween.TRANS_EXPO)
	tween.tween_subtween(GameManagerGlobal.game_ui.hide_tween(GameManagerGlobal.game_ui.portal_progress))
	tween.tween_subtween(GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.game_ui.look_backward_panel))
	tween.tween_subtween(GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.drag))
	tween.tween_subtween(GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.look_back))
	tween.tween_subtween(GameManagerGlobal.game_ui.show_tween(crosshair))
	tween.tween_property(self, "can_crawl", false, 0)
	tween.tween_property(quickflash, "can_flash", true, 0)
	return tween

func move_cam_forward() -> Tween:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_subtween(GameManagerGlobal.game_ui.hide_tween(GameManagerGlobal.game_ui.look_forward_panel))
	GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.flash)
	GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.look_forward)
	tween.tween_property(actual_cam, "rotation_degrees",front_cam.rotation_degrees, 1).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(actual_cam, "position", front_cam.position, 1).set_trans(Tween.TRANS_EXPO)
	if touching_portal:
		tween.tween_subtween(GameManagerGlobal.game_ui.show_tween(GameManagerGlobal.game_ui.portal_progress))
	tween.tween_subtween(GameManagerGlobal.game_ui.hide_tween(crosshair))
	tween.tween_property(self, "can_crawl", true, 0)
	tween.tween_property(quickflash, "can_flash", false, 0)
	return tween

func _unhandled_input(event: InputEvent) -> void:
	if can_crawl and not touching_portal:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			Input.set_custom_mouse_cursor(GRAB_CURSOR)
			dragging = event.pressed
		elif event is InputEventMouseMotion and dragging:
			Input.set_custom_mouse_cursor(GRAB_CURSOR)
			crawl.stream_paused = false
			GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.drag)
			handle_headbob(.01)
			var dragy = event.relative.y
			if dragy > 0.0:
				if dragy < 1.0:
					return
				drag_power += dragy * DRAG_TO_FORCE
				drag_power = clamp(drag_power, 0.0, 10.0)  # Max speed
		else:
			Input.set_custom_mouse_cursor(REGULAR_CURSOR)
			crawl.stream_paused = true

func _physics_process(delta: float) -> void:
	
	if can_crawl and touching_portal and Input.is_action_pressed("PrimaryClick"):
		portal.break_portal(delta)
	elif touching_portal:
		portal.recover_portal(delta)
	
	var forward: Vector3 = -global_transform.basis.z.normalized()
	
	velocity = forward * drag_power
	
	drag_power = lerp(drag_power, 0.0, DAMPING * delta)
	
	move_and_slide()






const head_bobbing_crouch_speed: float = 10.0
const head_bobbing_crouch_intensity: float = 0.03
var lerp_speed: float = 15.0
var head_bobbing_current_intensity: float = 0.0
var head_bobbing_index: float = 0.0
var head_bobbing_vector: Vector2 = Vector2.ZERO

var crouching_height: float = -1

func handle_headbob(delta: float) -> void:
	#rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
	#actual_cam.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
	actual_cam.rotation.x = clamp(actual_cam.rotation.x, deg_to_rad(-89),deg_to_rad(89))
	
	head_bobbing_vector.y = sin(head_bobbing_index)
	head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
	
	eyes.position.y = lerp(eyes.position.y,head_bobbing_vector.y*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
	eyes.position.x = lerp(eyes.position.x,head_bobbing_vector.x*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
	
	head_bobbing_current_intensity = head_bobbing_crouch_intensity
	head_bobbing_index += head_bobbing_crouch_speed * delta
	
	head.position.y = lerp(head.position.y, crouching_height, delta * lerp_speed)


func shiver_tween(duration: float, shivers: int) -> Tween:
	var divided_duration: float = duration / shivers
	var tween: Tween = get_tree().create_tween()
	for i: int in range(0, shivers):
		tween.tween_property(actual_cam, "rotation_degrees", Vector3(randf_range(-.5,.5), randf_range(-179.5,-180.5), randf_range(-1, 1)), divided_duration).set_trans(Tween.TRANS_EXPO)
	return tween

func die_tween() -> Tween:
	var tween: Tween = get_tree().create_tween()
	#var random_rotation: Vector3 =  Vector3(randf_range(-5,5), randf_range(-175,-185), randf_range(10,-10))
	for i in range(0,50):
		tween.tween_property(actual_cam, "rotation_degrees", Vector3(randf_range(-5,5), randf_range(-175,-185), randf_range(10,-10)), creature.jumpscare_length/100.0).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(actual_cam, "rotation_degrees", Vector3(0, -180, 0), creature.jumpscare_length/100.0).set_trans(Tween.TRANS_QUAD)
	return tween

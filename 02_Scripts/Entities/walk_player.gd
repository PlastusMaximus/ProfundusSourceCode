class_name WalkPlayer extends Player

signal inside()

enum States {
	WALKING,
	CROUCHING
}

@export var state: States = States.WALKING
@export_category("Movement")
@export var walking_speed: float = 2.5
@export var crouching_speed: float = 2.0
@export_category("Input")
@export var mouse_sens: float = 0.07

@onready var neck: Node3D = $Neck
@onready var head: Node3D = $Neck/Head
@onready var eyes: Node3D = $Neck/Head/Eyes
@onready var camera: Camera3D = $Neck/Head/Eyes/Camera
@onready var dim_flash: SpotLight3D = $Neck/Head/Eyes/Camera/dimFlash
@onready var quickflash: SpotLight3D = $Neck/Head/Eyes/Camera/quickflash
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var ambient_player_light: OmniLight3D = $AmbientPlayerLight
@onready var footsteps: AudioStreamPlayer = $Footsteps

# Movement Vars
var current_speed: float = 5.0
var lerp_speed: float = 15.0
var standing_height: float = 0
var crouching_height: float = -1
var direction: Vector3 = Vector3.ZERO
# camera vars
var free_look_tilt_amount: float = 5.0
# head bobbing
const head_bobbing_sprint_speed: float = 14.0
const head_bobbing_walk_speed: float = 14.0
const head_bobbing_crouch_speed: float = 10.0

const head_bobbing_sprint_intensity: float = 0.05
const head_bobbing_walk_intensity: float = 0.05
const head_bobbing_crouch_intensity: float = 0.03
var head_bobbing_current_intensity: float = 0.0

var head_bobbing_index: float = 0.0
var head_bobbing_vector: Vector2 = Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	footsteps.play()
	footsteps.stream_paused = true

func _input(event: InputEvent) -> void:
	# Überprüfen, ob die linke Maustaste gedrückt ist und kein Cooldown aktiv ist
	if event.is_action("Flash") and not quickflash.is_on_cooldown and quickflash.can_flash:
		quickflash.flash.emit()
		dim_flash.dim.emit()
	
	if event.is_action_pressed("Crouch") and not ray_cast_3d.is_colliding():
		if state == States.CROUCHING:
			state = States.WALKING
			await handle_uncrouching_tween().finished
		else:
			state = States.CROUCHING
			await handle_crouching_tween().finished
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89),deg_to_rad(89))
	
	

func handle_crouching_tween() -> Tween:
	var crouch_tween: Tween = create_tween().set_parallel(true)
	crouch_tween.tween_property(head, "position", Vector3(head.position.x, crouching_height, head.position.z), 1).set_trans(Tween.TRANS_EXPO)
	crouch_tween.tween_property(standing_collision_shape, "disabled", true, 0)
	crouch_tween.tween_property(crouching_collision_shape, "disabled", false, 0)
	return crouch_tween

func handle_uncrouching_tween() -> Tween:
	var uncrouch_tween: Tween = create_tween().set_parallel(true)
	uncrouch_tween.tween_property(head, "position", Vector3(head.position.x, standing_height, head.position.z), 1).set_trans(Tween.TRANS_EXPO)
	uncrouch_tween.tween_property(standing_collision_shape, "disabled", false, 0)
	uncrouch_tween.tween_property(crouching_collision_shape, "disabled", true, 0)
	return uncrouch_tween

func _physics_process(delta: float):
	# Getting movement input
	var input_dir = Input.get_vector("Move_Left", "Move_Right", "Move_Forward", "Move_Backward")
	if input_dir:
		footsteps.stream_paused = false
	else:
		footsteps.stream_paused = true
	# Movement
	
	handle_moving(delta)
	handle_headbob(delta, input_dir)
	# Add the gravity.
	handle_gravity(delta)
	# Determine the direction for movement
	set_direction(delta, input_dir)
	move_and_slide()

func handle_headbob(delta: float, input_dir: Vector2) -> void:
	if is_on_floor() && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y,head_bobbing_vector.y*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x,head_bobbing_vector.x*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y,0.0,delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x,0.0,delta*lerp_speed)

func handle_moving(delta: float) -> void:
	match state:
		States.WALKING:
			# Handle Speed
			current_speed = walking_speed
			# Handle headbob
			head_bobbing_current_intensity = head_bobbing_walk_intensity
			head_bobbing_index += head_bobbing_walk_speed * delta
		States.CROUCHING:
			# Handle Speed
			current_speed = crouching_speed
			# Handle headbob
			head_bobbing_current_intensity = head_bobbing_crouch_intensity
			head_bobbing_index += head_bobbing_crouch_speed * delta
	handle_walking(delta)

func handle_walking(delta: float) -> void:
	if !ray_cast_3d.is_colliding():
		if state == States.CROUCHING:
			head.position.y = lerp(head.position.y, crouching_height, delta * lerp_speed)
		else:
			head.position.y = lerp(head.position.y, standing_height, delta * lerp_speed)

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

## Get the input direction and handle the movement/deceleration.
## As good practice, you should replace UI actions with custom gameplay actions.
func set_direction(delta: float, input_dir: Vector2) -> void:
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

func _on_player_trigger_body_entered(body: Node3D) -> void:
	pass # Replace with function body.

class_name GameUI extends Control

const REGULAR_CURSOR: CompressedTexture2D = preload("uid://ccg66je0meiso")
const GRAB_CURSOR: CompressedTexture2D = preload("uid://degn6ri0cbf4g")
const FLASH_CURSOR: CompressedTexture2D = preload("uid://dbplxac1l20hb")

@onready var audio_visualization: AudioVisualization = $WalkieTalkieUI/AudioVisualization
@onready var flash_recharge: ProgressBar = $FlashRecharge
@onready var look_backward_panel: Panel = $LookBackwardPanel
@onready var look_forward_panel: Panel = $LookForwardPanel
@onready var portal_progress: ProgressBar = $Timer/PortalProgress

var recharge_timer: SceneTreeTimer

var player: CrawlPlayer

func _ready() -> void:
	look_backward_panel.hide()
	look_forward_panel.hide()
	portal_progress.hide()
	#GameManagerGlobal.game_ui.look_backward_panel.hide()
	#await get_tree().create_timer(5).timeout
	#cannot_turn_around_tween()
	#await get_tree().create_timer(5).timeout
	#can_turn_around_again_tween()

func set_player(new_player: CrawlPlayer) -> void:
	player = new_player
	flash_recharge.max_value = player.quickflash.cooldown_time
	look_backward_panel.show()

func recharge_flash(timer: SceneTreeTimer) -> void:
	recharge_timer = timer
	await recharge_timer.timeout
	recharge_timer = null

func hide_ui_for_walking() -> void:
	look_backward_panel.hide()
	look_forward_panel.hide()
	GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.look_back)
	GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.look_forward)
	GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.drag)
	GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.cannot_look_back)

func _process(_delta: float) -> void:
	if recharge_timer != null:
		flash_recharge.value = flash_recharge.max_value - recharge_timer.time_left
	else:
		flash_recharge.value = flash_recharge.max_value
	
	if player != null:
		if player.touching_portal and player.can_crawl:
			portal_progress.value = player.portal.time_to_break

func _on_look_back_panel_mouse_entered() -> void:
	if player != null:
		player.turn_back_tween()

func let_stuff_appear_on_the_back() -> Tween:
	var tween = create_tween().set_parallel(true)
	tween.tween_subtween(show_tween(player.crosshair))
	tween.tween_callback(Input.set_custom_mouse_cursor.bind(FLASH_CURSOR))
	tween.tween_property(Input, "mouse_mode", Input.MOUSE_MODE_VISIBLE, 0)
	tween.tween_subtween(show_tween(look_forward_panel))
	tween.tween_subtween(GameManagerGlobal.tutorial.show_tween(GameManagerGlobal.tutorial.flash))
	return tween

func _on_look_forward_panel_mouse_entered() -> void:
	if player != null:
		player.turn_forward_tween()

func let_stuff_appear_front() -> Tween:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_callback(Input.set_custom_mouse_cursor.bind(REGULAR_CURSOR))
	tween.tween_property(Input, "mouse_mode", Input.MOUSE_MODE_VISIBLE, 0)
	tween.tween_subtween(show_tween(look_backward_panel))
	tween.tween_subtween(GameManagerGlobal.tutorial.show_tween(GameManagerGlobal.tutorial.drag))
	return tween

func cannot_turn_around_tween() -> Tween:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(look_backward_panel, "modulate", Color.RED, 1)
	tween.tween_subtween(GameManagerGlobal.tutorial.show_tween(GameManagerGlobal.tutorial.cannot_look_back))
	tween.tween_property(look_backward_panel, "mouse_filter", MOUSE_FILTER_IGNORE, 0)
	return tween

func can_turn_around_again_tween() -> Tween:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(look_backward_panel, "modulate", Color.WHITE, 1)
	tween.tween_subtween(GameManagerGlobal.tutorial.hide_tween(GameManagerGlobal.tutorial.cannot_look_back))
	tween.tween_property(look_backward_panel, "mouse_filter", MOUSE_FILTER_STOP, 0)
	return tween

func show_tween(panel: Control) -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.tween_callback(panel.show)
	tween.tween_property(panel, "modulate", Color.WHITE, StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_QUAD)
	return tween

func hide_tween(panel: Control) -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(panel, "modulate", Color.TRANSPARENT, StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(panel.hide)
	return tween

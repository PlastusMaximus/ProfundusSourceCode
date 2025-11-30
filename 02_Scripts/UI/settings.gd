class_name Settings extends Control

@onready var music_setting: SliderSetting = $TabContainer/Sound/Sound/VBoxContainer/Music_Setting
@onready var sfx_setting: SliderSetting = $TabContainer/Sound/Sound/VBoxContainer/SFX_Setting
@onready var language_setting: SelectorSetting = $TabContainer/Sound/Sound/VBoxContainer/LanguageSetting
@onready var hide_button: Button = $TabContainer/Sound/Sound/VBoxContainer/Hide

func _ready() -> void:
	GameManagerGlobal.language_changed.connect(_on_language_changed)
	get_tree().scene_changed.connect(_on_scene_changed)
	hide()

func appear_tween() -> Tween:
	show()
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", Vector2.ZERO, StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_ELASTIC).from(Vector2(-350, 0))
	return tween

func _disappear_tween() -> Tween:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", Vector2(-350, 0), StatManagerGlobal.ui_speed).set_trans(Tween.TRANS_ELASTIC)
	return tween

func _on_hide_pressed() -> void:
	await _disappear_tween().finished
	hide()

func _on_music_setting_value_changed(value: float) -> void:
	StatManagerGlobal.music_volume = value / 100
	#for music_node: AudioStreamPlayer in get_tree().get_nodes_in_group("Music"):
		#music_node.volume_linear = StatManagerGlobal.music_volume
	AudioServer.set_bus_volume_linear(1, StatManagerGlobal.music_volume)

func _on_sfx_setting_value_changed(value: float) -> void:
	StatManagerGlobal.sfx_volume = value / 100
	#for sfx_node in get_tree().get_nodes_in_group("SFX"):
		#sfx_node.volume_linear = StatManagerGlobal.sfx_volume
	AudioServer.set_bus_volume_linear(3, StatManagerGlobal.sfx_volume)
	

func _on_scene_changed() -> void:
	music_setting.value_changed.emit(StatManagerGlobal.music_volume * 100)
	sfx_setting.value_changed.emit(StatManagerGlobal.sfx_volume * 100)

func _on_language_setting_index_changed(index: int) -> void:
	match index:
		0:
			GameManagerGlobal.change_language.emit(StatManager.Languages.GERMAN)
		1:
			GameManagerGlobal.change_language.emit(StatManager.Languages.ENGLISH)

func _on_language_changed() -> void:
	match StatManagerGlobal.game_language:
		StatManager.Languages.GERMAN:
			music_setting.setting_name = "Musik"
			music_setting.info.text = "Musik:"
			sfx_setting.setting_name = "Effekte"
			sfx_setting.info.text = "Effekte:"
			language_setting.setting_name = "Sprache"
			language_setting.info.text = "Sprache:"
			hide_button.text = "Verstecken"
		StatManager.Languages.ENGLISH:
			music_setting.setting_name = "Music"
			music_setting.info.text = "Music:"
			sfx_setting.setting_name = "SFX"
			sfx_setting.info.text = "SFX:"
			language_setting.setting_name = "Language"
			language_setting.info.text = "Language:"
			hide_button.text = "Hide"

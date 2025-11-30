class_name LoadManager extends Node

##Updates the listeners with the progress of the loading screen (example values: 100% = 1.0, 50% = 0.5)
signal progress_changed(progress: float)
##Informs the listeners that the loading process is done
signal load_done()

var _load_screen_path: String = "res://01_Scenes/UI/loading_screen.tscn"
var _load_screen = load(_load_screen_path)
var _loaded_resource: PackedScene
var _scene_path: String
var _progress: Array = []

var use_sub_threads: bool = true

##Quits the game gracefully with the help of a loading screen
func quit_game() -> void:
	var new_loading_screen: LoadingScreen = _load_screen.instantiate()
	GameManagerGlobal.ui_layer.add_child(new_loading_screen)
	new_loading_screen._update_progress_bar(25)
	
	self.progress_changed.connect(new_loading_screen._update_progress_bar)
	new_loading_screen._update_progress_bar(50)
	self.load_done.connect(new_loading_screen._start_outro_animation)
	new_loading_screen._update_progress_bar(75)
	
	await new_loading_screen.loading_screen_has_full_coverage
	new_loading_screen._update_progress_bar(100)
	get_tree().quit()

##Loads a new scene based on it's file path.
##Visualizes the process with the help of a loading screen.
func load_scene(scene_path: String) -> void:
	_scene_path = scene_path
	
	var new_loading_screen: LoadingScreen = _load_screen.instantiate()
	GameManagerGlobal.ui_layer.add_child(new_loading_screen)
	
	self.progress_changed.connect(new_loading_screen._update_progress_bar)
	self.load_done.connect(new_loading_screen._start_outro_animation)
	
	await new_loading_screen.loading_screen_has_full_coverage
	
	start_load()

##Starts the loading process of the ResourceLoader
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta: float) -> void:
	var load_status: int = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_changed.emit(_progress.front())
		ResourceLoader.THREAD_LOAD_LOADED:
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
			progress_changed.emit(_progress.front())
			load_done.emit()
			get_tree().change_scene_to_packed(_loaded_resource)

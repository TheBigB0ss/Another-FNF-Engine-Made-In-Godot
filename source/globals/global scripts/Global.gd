extends Node

var cur_thing = 0;
var finished_intro = false;
var can_use_menus = true;
var is_on_video = false;

signal end_dialogue;
signal end_cutscene;
signal end_senpai_cutscene;
signal end_tankman_cutscene;

func _ready():
	update_windowMode(GlobalOptions.full_screen);
	update_vsync(GlobalOptions.vsync);
	
func _process(delta: float) -> void:
	Engine.max_fps = GlobalOptions.fps;
	
func get_key(key_code):
	var ev = InputEventKey.new();
	ev.keycode = GlobalOptions.keys[key_code][0];
	return ev.keycode;
	
func getFolderShit(folder):
	var file = [];
	var coolFolder = DirAccess.open("res://%s"%[folder]);
	var nextFolder = coolFolder.get_next();
	
	if nextFolder != "":
		file.append(nextFolder);
		
	return file;
	
func getTextFromTxt(path):
	var txt = "res://assets/%s.txt"%[path];
	var readTxt = FileAccess.open(txt,FileAccess.READ);
	var file = readTxt.get_as_text();
	return file;
	
func getTextFromJson(path):
	var json = "res://assets/%s.json"%[path];
	var file = FileAccess.open(json, FileAccess.READ);
	var fileData = JSON.parse_string(file.get_as_text());
	return fileData;
	
func getTime():
	var time = Time.get_time_dict_from_system();
	return time;
	
func getUserName():
	var user = OS.get_environment("USERNAME");
	return user;
	
func closeGame():
	get_tree().quit();
	
func update_windowMode(toggle):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggle else DisplayServer.WINDOW_MODE_WINDOWED);
	
func update_vsync(toggle):
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggle else DisplayServer.VSYNC_DISABLED);
	
func changeScene(scene, useTransition = true, use_stickers = true):
	process_mode = 2 if get_tree().paused else 0;
	
	if useTransition:
		Transition._is_in_transition(use_stickers);
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://source/%s.tscn"%[scene]);
	else:
		get_tree().change_scene_to_file("res://source/%s.tscn"%[scene]);
		
func reloadScene(useTrasition = true, use_stickers = false, speed = 0.65):
	process_mode = 2 if get_tree().paused else 0;
	
	if useTrasition:
		Transition.transition_speed = speed;
		Transition._is_in_transition(use_stickers);
		
		await get_tree().create_timer(1.0).timeout
		get_tree().reload_current_scene();
	else:
		get_tree().reload_current_scene();
		
func global_get_week_files():
	var file = [];
	var coolFolder = DirAccess.open("res://assets/data/weeks data/%s"%[SongData.week_folder_path]);
	if coolFolder:
		coolFolder.list_dir_begin();
		var nameShit = coolFolder.get_next();
		while nameShit != "":
			file.append(nameShit.replace(".json", ""));
			nameShit = coolFolder.get_next();
			
	return file;
	

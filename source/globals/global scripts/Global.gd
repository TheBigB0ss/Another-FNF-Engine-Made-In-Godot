extends Node

signal end_dialogue;
signal end_cutscene;

signal on_death_screen;
signal on_death_confirm;

var finished_intro = false;
var can_use_menus = true;
var is_on_video = false;

var current_selected = {
	"storyMode": 0,
	"freeplay": 0,
	"credits": 0,
	"options": 0,
	"achievements": 0,
	"mainmenu": 0
};

var currentStoryMode = 0:
	set(val):
		if currentStoryMode != val:
			currentStoryMode = val;
			current_selected["storyMode"] = currentStoryMode;
			
var currentFreeplay = 0:
	set(val):
		if currentFreeplay != val:
			currentFreeplay = val;
			current_selected["freeplay"] = currentFreeplay;
			
var currentCredits = 0:
	set(val):
		if currentCredits != val:
			currentCredits = val;
			current_selected["credits"] = currentCredits;
			
var currentOptions = 0:
	set(val):
		if currentOptions != val:
			currentOptions = val;
			current_selected["options"] = currentOptions;
			
var currentAchievements = 0:
	set(val):
		if currentAchievements != val:
			currentAchievements = val;
			current_selected["achievements"] = currentAchievements;
			
var currentMainMenu = 0:
	set(val):
		if currentMainMenu != val:
			currentMainMenu = val;
			current_selected["mainmenu"] = currentMainMenu;
			
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
func getTime():
	var time = Time.get_time_dict_from_system();
	return time;
	
func getUserName():
	var user = OS.get_environment("USERNAME");
	return user;
	
func closeGame():
	get_tree().quit();
	
func changeScene(scene, useTransition = true, use_stickers = true):
	if useTransition:
		Transition._is_in_transition(use_stickers);
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://source/%s.tscn"%[scene]);
	else:
		get_tree().change_scene_to_file("res://source/%s.tscn"%[scene]);
		
func reloadScene(useTrasition = true, use_stickers = false):
	if useTrasition:
		Transition._is_in_transition(use_stickers);
		await get_tree().create_timer(1.0).timeout
		get_tree().reload_current_scene();
	else:
		get_tree().reload_current_scene();
		
func update_cursor(cursor):
	Input.set_custom_mouse_cursor(load("res://assets/images/cursors/cursor-%s.png"%[cursor]), Input.CURSOR_ARROW, Vector2.ZERO);
	
func has_dialogue():
	var base = "res://assets/songs/%s/chart/%sDialogue"%[SongData.song, SongData.song];
	return (FileAccess.file_exists(base + ".txt") || FileAccess.file_exists(base + ".json"));
	
func load_json(path = ""):
	var jsonFile = FileAccess.open("res://"+path+".json", FileAccess.READ);
	var json = JSON.new();
	json.parse(jsonFile.get_as_text());
	jsonFile.close();
	return json.get_data();
	
func get_folder(folder, onlyDirs = false):
	var file = [];
	var coolFolder = DirAccess.open("res://%s"%[folder]);
	if coolFolder:
		coolFolder.list_dir_begin();
		
		var nameShit = coolFolder.get_next();
		while nameShit != "":
			if !nameShit.begins_with("."):
				if !onlyDirs or coolFolder.current_is_dir():
					file.append(nameShit);
					
			nameShit = coolFolder.get_next();
			
		coolFolder.list_dir_end();
	return file;
	

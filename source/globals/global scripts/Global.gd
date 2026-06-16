extends Node

signal end_dialogue;
signal end_cutscene;
signal end_senpai_cutscene;
signal end_tankman_cutscene;

var finished_intro = false;
var can_use_menus = true;
var is_on_video = false;

var currentStoryMode = 0:
	set(val):
		if currentStoryMode != val:
			currentStoryMode = val;
			save_current_statu();
			
var currentFreeplay = 0:
	set(val):
		if currentFreeplay != val:
			currentFreeplay = val;
			save_current_statu();
			
var currentCredits = 0:
	set(val):
		if currentCredits != val:
			currentCredits = val;
			save_current_statu();
			
var currentOptions = 0:
	set(val):
		if currentOptions != val:
			currentOptions = val;
			save_current_statu();
			
var currentAchievements = 0:
	set(val):
		if currentAchievements != val:
			currentAchievements = val;
			save_current_statu();
			
var currentMainMenu = 0:
	set(val):
		if currentMainMenu != val:
			currentMainMenu = val;
			save_current_statu();
			
var current_selected = {
	"storyMode": 0,
	"freeplay": 0,
	"credits": 0,
	"options": 0,
	"achievements": 0,
	"mainmenu": 0
};

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
func save_current_statu():
	current_selected["storyMode"] = currentStoryMode;
	current_selected["freeplay"] = currentFreeplay;
	current_selected["credits"] = currentCredits;
	current_selected["options"] = currentOptions;
	current_selected["achievements"] = currentAchievements;
	current_selected["mainmenu"] = currentMainMenu;
	
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
	

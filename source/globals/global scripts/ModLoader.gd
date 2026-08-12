extends Node

var mods = [];

func _ready() -> void:
	loadMod();
	
func loadMod():
	var mods_path = OS.get_executable_path().get_base_dir().path_join("mods");
	var dir = DirAccess.open(mods_path);
	
	if !DirAccess.dir_exists_absolute(mods_path):
		var error = DirAccess.make_dir_absolute(mods_path);
		if error != OK:
			push_error("fail on create: " + mods_path);
			
		return;
		
	if dir == null:
		return;
		
	dir.list_dir_begin();
	var fileName = dir.get_next();
	while fileName != "":
		if !dir.current_is_dir():
			fileName = dir.get_next();
			continue;
			
		var mod_folder = mods_path.path_join(fileName);
		var pck_path = mod_folder.path_join(fileName + ".pck");
		
		if FileAccess.file_exists(pck_path):
			if ProjectSettings.load_resource_pack(pck_path, true):
				mods.append(fileName);
				
		fileName = dir.get_next();
		
	dir.list_dir_end();
	
func load_json(path):
	var mods_path = OS.get_executable_path().get_base_dir().path_join("mods");
	var full_path = mods_path.path_join(path + ".json");
	var file = FileAccess.open(full_path, FileAccess.READ);
	if file == null:
		return {
			"name": "your mod name",
			"discretion": "your mod discretion",
			"version": "1.0",
			"mod icon": "engine_icon",
			"author": "your name"
		};
		
	var json = JSON.new();
	json.parse(file.get_as_text());
	file.close();
	
	return json.get_data();

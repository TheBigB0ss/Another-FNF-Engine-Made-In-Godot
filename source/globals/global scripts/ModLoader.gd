extends Node

var mods = [];

func _init() -> void:
	load_mods();
	
func load_mods() -> void:
	var mods_path = OS.get_executable_path().get_base_dir().path_join("mods");
	
	if !DirAccess.dir_exists_absolute(mods_path):
		var error = DirAccess.make_dir_recursive_absolute(mods_path);
		if error != OK:
			return;
			
		return;
		
	var dir = DirAccess.open(mods_path);
	
	if dir == null:
		return;
		
	dir.list_dir_begin();
	
	var file_name = dir.get_next();
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next();
			continue;
			
		if !dir.current_is_dir() && file_name.get_extension().to_lower() == "pck":
			load_mod_file(file_name, mods_path);
			
		file_name = dir.get_next();
		
	dir.list_dir_end();
	
func load_mod_file(file_name, mods_path):
	var pck_path = mods_path.path_join(file_name);
	if !FileAccess.file_exists(pck_path):
		return;
		
	ProjectSettings.load_resource_pack(pck_path, true);
	
#func load_json(path):
	#var mods_path = OS.get_executable_path().get_base_dir().path_join("mods");
	#var full_path = mods_path.path_join(path + ".json");
	#var file = FileAccess.open(full_path, FileAccess.READ);
	#if file == null:
		#return {
			#"name": "your mod name",
			#"discretion": "your mod discretion",
			#"version": "1.0",
			#"mod icon": "engine_icon",
			#"author": "your name"
		#};
		#
	#var json = JSON.new();
	#json.parse(file.get_as_text());
	#file.close();
	#
	#return json.get_data();

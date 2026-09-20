extends Node

func _init() -> void:
	load_mods();
	
func load_mods() -> void:
	var mods_path = OS.get_executable_path().get_base_dir().path_join("mods");
	
	if !DirAccess.dir_exists_absolute(mods_path):
		if DirAccess.make_dir_recursive_absolute(mods_path) != OK:
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
			
		var path = mods_path.path_join(file_name);
		
		if dir.current_is_dir():
			load_mod_folder(path);
		elif file_name.get_extension().to_lower() == "pck":
			load_mod_file(file_name, mods_path);
			
		file_name = dir.get_next();
		
	dir.list_dir_end();
	
func load_mod_file(file_name, mods_path):
	var pck_path = mods_path.path_join(file_name);
	if !FileAccess.file_exists(pck_path):
		return;
		
	ProjectSettings.load_resource_pack(pck_path, true);
	
func load_mod_folder(folder_path):
	var dir = DirAccess.open(folder_path);
	
	if dir == null:
		return;
		
	dir.list_dir_begin();
	
	var file_name = dir.get_next();
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next();
			continue;
			
		if !dir.current_is_dir() && file_name.get_extension().to_lower() == "pck":
			load_mod_file(file_name, folder_path);
			
		file_name = dir.get_next();
		
	dir.list_dir_end();
	

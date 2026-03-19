extends Node

var mods_data = {
	"songs": [],
	"stages": [],
	"fonts": [],
	"images": [],
	"music": [],
	"sounds": [],
	"weeks data": [],
	"characters data": [],
	"songs data": [],
	"stage data": [],
	"stage scene": [],
	"stage scripts": [],
	"characters scene": [],
	"icons": [],
	"song cards": [],
	"characters sprites": [],
	"credits icons": [],
	"difficulties": [],
	"weeks spr": []
};

#func _ready() -> void:
	#create_folders();
	#var mods_path = OS.get_executable_path().get_base_dir()+"/mods";
	#
	#mods_data["weeks data"] = load_assets(mods_path+"/data/weeks data", ".json");
	#mods_data["characters data"] = load_assets(mods_path+"/data/characters", ".json");
	#mods_data["stage data"] = load_assets(mods_path+"/data/stages data", ".json");
	#mods_data["songs data"] = load_assets(mods_path+"/data/songs", ".json");
	#
	#mods_data["images"] = load_assets(mods_path+"/images", ".png");
	#mods_data["fonts"] = load_assets(mods_path+"/fonts", ".ttf");
	#
	#mods_data["stages"] = load_assets(mods_path+"/stages", ".png");
	#mods_data["songs"] = load_assets(mods_path+"/songs", ".ogg");
	#mods_data["music"] = load_assets(mods_path+"/music", ".ogg");
	#
	#mods_data["stage scripts"] = load_assets(mods_path+"/stages scene/", ".gdscript");
	#mods_data["stage scene"] = load_assets(mods_path+"/stages scene/", ".tscn");
	#mods_data["characters scene"] = load_assets(mods_path+"/characters scene", ".gdscript");
	#
	#mods_data["icons"] = load_assets(mods_path+"/images/icon", ".png");
	#mods_data["song cards"] = load_assets(mods_path+"/images/song_cards", ".png");
	#mods_data["credits icons"] = load_assets(mods_path+"/images/credits icons", ".png");
	#mods_data["characters sprites"] = load_assets(mods_path+"/images/characters", ".png");
	#mods_data["difficulties"] = load_assets(mods_path+"/images/difficulties", ".png");
	#mods_data["weeks spr"] = load_assets(mods_path+"/images/weeks", ".png");
	
#func create_folders():
	#var exe_path = OS.get_executable_path();
	#var base_dir = exe_path.get_base_dir();
	#
	#var dir = DirAccess.open(base_dir);
	#if !dir.dir_exists("mods"):
		#dir.make_dir("mods");
		#
	#var folder_list = [
		#"songs",
		#"stages",
		#"fonts",
		#"images",
		#"music",
		#"sounds",
		#"images/icons",
		#"images/characters",
		#"images/difficulties",
		#"images/credits",
		#"images/song_cards",
		#"images/weeks",
		#"data/weeks data",
		#"data/characters data",
		#"data/songs data",
		#"data/stage data",
		#"stages scenes"
	#];
	#
	#for j in folder_list:
		#var folder_path = base_dir+"/mods"+"/"+j;
		#DirAccess.make_dir_recursive_absolute(folder_path);
		
func load_assets(loc, type):
	var file = [];
	var coolFolder = DirAccess.open(loc);
	
	if coolFolder:
		coolFolder.list_dir_begin();
		var nameShit = coolFolder.get_next();
		
		while nameShit != "":
			var file_loc = loc+"/"+nameShit;
			if coolFolder.current_is_dir():
				file += load_assets(file_loc, type);
			else:
				if nameShit.ends_with(type):
					file.append(file_loc)
					
			nameShit = coolFolder.get_next();
			
	return file;
	
func load_files(path):
	var asset_path = OS.get_executable_path().get_base_dir()+"/mods/"+path;
	if FileAccess.file_exists(asset_path):
		return ResourceLoader.load(asset_path);
	return null;

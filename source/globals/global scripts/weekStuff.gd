class_name weekStuff extends Node2D

var weekJson = {
	"songs": [[]],
	"hideFromFreeplay": false,
	"hideFromStoryMode": false,
	"isLocked": false,
	"weekName": "",
	"lastWeek": "",
	"weekDescription": "",
	"weekCharacters": [],
	"weekDifficulties": []
}

func get_week_files():
	var file = [];
	var coolFolder = DirAccess.open("res://assets/weeks/%s"%[Global.week_path]);
	if coolFolder:
		coolFolder.list_dir_begin();
		var nameShit = coolFolder.get_next();
		while nameShit != "":
			file.append(nameShit.replace(".json", ""));
			nameShit = coolFolder.get_next();
			
	return file;

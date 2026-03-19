extends Node

var achievements = {};
var devMode = false;

signal end_achievement;

func _ready():
	#reset_achievements();
	load_achievements();
	
	if !achievements.has("version") or achievements["version"] != 1:
		reset_achievements();
		
	if devMode:
		for i in achievements.keys():
			if i != "version":
				achievements[i]["value"] = true;
				achievements[i]["secret achievement"] = false;
				
	for i in achievements.keys():
		if i != "version":
			if !achievements[i].has("special achievement"):
				achievements[i]["special achievement"] = false;
				
func unlock_achievement(achievement):
	if typeof(achievements[achievement]["value"]) == TYPE_BOOL:
		if achievements[achievement]["value"] == false:
			unlock_int_achievement(achievement, "almost there", 7, 0);
			unlock_int_achievement(achievement, "rap god", 16, 9);
			unlock_int_achievement(achievement, "funkin master", 23, 0);
			
			achievements[achievement]["value"] = true;
			achievements[achievement]["secret achievement"] = false;
			save_achievements();
			
func unlock_int_achievement(achievement, new_achievement, max_val, min_val):
	if achievements[achievement]["achievement index"] >= min_val && achievements[achievement]["achievement index"] <= max_val && achievements[new_achievement]["value"][0] < achievements[new_achievement]["value"][1]:
		achievements[new_achievement]["value"][0] += 1;
		
		if achievements[new_achievement]["value"][0] == achievements[new_achievement]["value"][1] && !achievements[new_achievement]["value"][2]:
			AchievementPopUp.set_achievement(new_achievement, true if SongData.isPlaying else false);
			achievements[new_achievement]["secret achievement"] = false;
			achievements[new_achievement]["value"][2] = true;
			print(achievements[new_achievement]["value"][2])
			
func get_achievement(achievement_name):
	for i in achievements.keys():
		if achievements[i] == achievement_name:
			return i;
			
func get_achievement_info(achievement_name):
	for i in achievements.keys():
		if i == achievement_name && achievement_name != "version":
			return {
				"achievement_name": i,
				"achievement_value": achievements[i]["value"],
				"achievement_description": achievements[i]["description"],
				"achievement_hide": achievements[i]["secret achievement"],
				"achievement_index": achievements[i]["achievement index"],
				"achievement_special": achievements[i]["special achievement"]
			};
			
func load_achievements():
	if FileAccess.file_exists("user://achievementSave.json"):
		var new_jsonFile = FileAccess.open("user://achievementSave.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		achievements = jsonData.get_data();
		new_jsonFile.close();
	else:
		reset_achievements();
		
func save_achievements():
	var new_jsonFile = FileAccess.open("user://achievementSave.json", FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(achievements));
	new_jsonFile.close();
	
func reset_achievements():
	achievements = {
		"version": 1,
		"you can do it":{
			"description": "beat tutorial",
			"value": false,
			"secret achievement": false,
			"achievement index": 0
		},
		"a new rapper":{
			"description": "beat week 1",
			"value": false,
			"secret achievement": false,
			"achievement index": 1
		},
		"trick or treat":{
			"description": "beat week 2",
			"value": false,
			"secret achievement": false,
			"achievement index": 2
		},
		"since 99's":{
			"description": "beat week 3",
			"value": false,
			"secret achievement": false,
			"achievement index": 3
		},
		"what is a milf":{
			"description": "beat week 4",
			"value": false,
			"secret achievement": false,
			"achievement index": 4
		},
		"a christmas special":{
			"description": "beat week 5",
			"value": false,
			"secret achievement": false,
			"achievement index": 5
		},
		"so retro":{
			"description": "beat week 6",
			"value": false,
			"secret achievement": false,
			"achievement index": 6
		},
		"what we got here":{
			"description": "beat week 7",
			"value": false,
			"secret achievement": false,
			"achievement index": 7
		},
		"almost there":{
			"description": "beat all weeks",
			"value": [0, 8, false],
			"secret achievement": false,
			"achievement index": 8
		},
		"a new begin":{
			"description": "beat tutorial on hard",
			"value": false,
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 9
		},
		"a new rockstar":{
			"description": "beat week 1 on hard",
			"value": false,
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 10
		},
		"spooky scary skeletons":{
			"description": "beat week 2 on hard",
			"value": false,
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 11
		},
		"go pico go":{
			"description": "beat week 3 on hard",
			"value": false,
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 12
		},
		"highway troubles":{
			"description": "beat week 4 on hard",
			"value": false,
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 13
		},
		"rip and tear":{
			"description": "beat week 5 on hard",
			"value": false,
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 14
		},
		"your gf is in another castle":{
			"description": "beat week 6 on hard",
			"value": false,
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 15
		},
		"war never change":{
			"description": "beat week 7 on hard",
			"value": false,
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 16
		},
		"rap god":{
			"description": "beat all weeks on hard",
			"value": [0, 8, false],
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 17
		},
		"fucked up":{
			"description": "finish a song with low health",
			"value": false,
			"special achievement": false,
			"secret achievement": false,
			"achievement index": 18
		},
		"what time is it":{
			"description": "IT'S TV TIME!!!",
			"value": false,
			"special achievement": true,
			"secret achievement": true,
			"achievement index": 19
		},
		"debug mode":{
			"description": "beat test song",
			"value": false,
			"special achievement": false,
			"secret achievement": true,
			"achievement index": 20
		},
		"combo master":{
			"description": "complete a song with FC",
			"value": false,
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 21
		},
		"perfectionist":{
			"description": "complete a song with SFC or GFC",
			"value": false,
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 22
		},
		"funkin master":{
			"description": "unlock all achievements",
			"value": [0, 23, false],
			"special achievement": true,
			"secret achievement": false,
			"achievement index": 23
		}
	};
	
	save_achievements();
	
#here to you add your own achievement
func add_achievement(achievement_name, description, value, special_achievement, secret_achievement, achievement_index):
	load_achievements();
	if !achievements.has(achievement_name):
		achievements[achievement_name] = {
			"description": description,
			"value": value,
			"special achievement": special_achievement,
			"secret achievement": secret_achievement,
			"achievement index": achievement_index
		};
		
	save_achievements();
	
#here if you want to remove a specific achievement
func remove_achievement(achievement_name):
	load_achievements();
	if achievements.has(achievement_name):
		achievements.erase(achievement_name);
		
	save_achievements();

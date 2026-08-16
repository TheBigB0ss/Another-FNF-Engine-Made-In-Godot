extends Node

var achievements = {};

var progress = 0;
var total_achievements = 0;
var owned_achievements = 0;

signal end_achievement;

func _ready():
	#reset_achievements();
	load_achievements();
	
	var defaultAchievements = Global.load_json("assets/data/achievements");
	
	for i in defaultAchievements:
		if !achievements.has(i):
			var ids = defaultAchievements[i].get("ids", []);
			
			var achievementId1 = -1;
			var achievementId2 = -1;
			
			if ids.size() >= 2:
				achievementId1 = ids[0];
				achievementId2 = ids[1];
				
			add_achievement(
				i, 
				defaultAchievements[i]["description"], 
				defaultAchievements[i]["value"], 
				defaultAchievements[i].get("special achievement", false),
				defaultAchievements[i].get("secret achievement", false),
				defaultAchievements[i]["achievement index"],
				achievementId1,
				achievementId2
			);
			
	for i in achievements.keys():
		if !defaultAchievements.has(i):
			remove_achievement(i);
			
	for i in achievements.keys():
		if !achievements[i].has("special achievement"):
			achievements[i]["special achievement"] = false;
			
		total_achievements += 1;
		
	update_achievement_stats();
	
func update_achievement_stats():
	owned_achievements = 0;
	
	for i in achievements:
		if check_achievement_status(i):
			owned_achievements += 1;
			
	progress = snapped((float(owned_achievements) / total_achievements) * 100, 1);
	
func unlock_achievement(achievement):
	if typeof(achievements[achievement]["value"]) == TYPE_BOOL:
		if !achievements[achievement]["value"]:
			for i in ["almost there", "rap god", "funkin master"]:
				update_achievement_progress(achievement, i, achievements[i]["ids"][0], achievements[i]["ids"][1]);
				
			achievements[achievement]["value"] = true;
			achievements[achievement]["secret achievement"] = false;
			
	elif typeof(achievements[achievement]["value"]) == TYPE_ARRAY:
		if achievements[achievement]["value"][0] < achievements[achievement]["value"][1]:
			achievements[achievement]["value"][0] += 1;
			
			if achievements[achievement]["value"][0] == achievements[achievement]["value"][1] && !achievements[achievement]["value"][2]:
				achievements[achievement]["value"][2] = true;
				achievements[achievement]["secret achievement"] = false;
				AchievementPopUp.set_achievement(achievement, SongData.isPlaying);
				
	save_achievements();
	
func update_achievement_progress(achievement, new_achievement, min_val, max_val):
	if achievements[achievement]["achievement index"] >= min_val && achievements[achievement]["achievement index"] <= max_val && achievements[new_achievement]["value"][0] < achievements[new_achievement]["value"][1]:
		achievements[new_achievement]["value"][0] += 1;
		
		if achievements[new_achievement]["value"][0] == achievements[new_achievement]["value"][1] && !achievements[new_achievement]["value"][2]:
			achievements[new_achievement]["value"][2] = true;
			achievements[new_achievement]["secret achievement"] = false;
			AchievementPopUp.set_achievement(new_achievement, SongData.isPlaying);
			
func check_achievement_status(achievement):
	match typeof(achievements[achievement]["value"]):
		TYPE_BOOL: 
			return achievements[achievement]["value"];
		TYPE_ARRAY:
			return achievements[achievement]["value"][2] or achievements[achievement]["value"][0] == achievements[achievement]["value"][1];
	return false;
	
func get_achievement_info(achievement_name):
	for i in achievements.keys():
		if i == achievement_name:
			return {
				"achievement_name": i,
				"achievement_value": achievements[i]["value"],
				"achievement_description": achievements[i]["description"],
				"achievement_hide": achievements[i]["secret achievement"],
				"achievement_index": achievements[i]["achievement index"],
				"achievement_special": achievements[i]["special achievement"]
			};
			
func reset_achievements():
	achievements = Global.load_json("assets/data/achievements");
	save_achievements();
	
func add_achievement(achievement_name, description, value, special_achievement, secret_achievement, achievement_index, achievementId1 = -1, achievementId2 = -1):
	load_achievements();
	if !achievements.has(achievement_name):
		achievements[achievement_name] = {
			"description": description,
			"value": value,
			"special achievement": special_achievement,
			"secret achievement": secret_achievement,
			"achievement index": achievement_index
		};
		if achievementId1 > -1 && achievementId2 > -1:
			achievements[achievement_name]["ids"] = [achievementId1, achievementId2];
			
	save_achievements();
	
func remove_achievement(achievement_name):
	load_achievements();
	if achievements.has(achievement_name):
		achievements.erase(achievement_name);
		
	save_achievements();
	
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
	
	update_achievement_stats();

class_name Achievements_icon extends Node2D

var shit = "";
var cool_name = "";
var cool_value = false;
var cool_description = "";
var hidden_achievement = false;

var max_value = 0;
var min_value = 0;

var achievement_ID = 0;

var suffix_x = 0;
var suffix_y = 0;

var achievement_grp = Node2D.new();
var achievement_spr = Sprite2D.new();

func _ready() -> void:
	var coolest_point = "";
	add_child(achievement_grp);
	
	match typeof(Achievements.get_achievement_info(cool_name)["achievement_value"]):
		TYPE_BOOL:
			cool_value = Achievements.get_achievement_info(cool_name)["achievement_value"];
			cool_description = Achievements.get_achievement_info(cool_name)["achievement_description"];
			
		TYPE_ARRAY:
			min_value = Achievements.get_achievement_info(cool_name)["achievement_value"][0];
			max_value = Achievements.get_achievement_info(cool_name)["achievement_value"][1];
			cool_description = str(
				Achievements.get_achievement_info(cool_name)["achievement_description"], ": ", Achievements.get_achievement_info(cool_name)["achievement_value"][0], " / ", Achievements.get_achievement_info(cool_name)["achievement_value"][1]
			);
			
			cool_value = (min_value == max_value);
			
	hidden_achievement = Achievements.get_achievement_info(cool_name)["achievement_hide"];
	
	var achievementBgSpr = "AchievementBgBasic" if !Achievements.get_achievement_info(cool_name)["achievement_special"] else "AchievementBgRare";
	var achievementBg = Sprite2D.new();
	achievementBg.texture = load("res://assets/images/achievements/%s.png"%[achievementBgSpr]);
	achievementBg.position = Vector2(achievement_spr.position.x, achievement_spr.position.y);
	achievement_grp.add_child(achievementBg);
	
	if cool_value:
		var coolPath = "res://assets/images/achievements/icons/%s.png"%[cool_name];
		if ResourceLoader.exists(coolPath, "Texture2D"):
			achievement_spr.texture = load(coolPath);
		else:
			achievement_spr.texture = load("res://assets/images/achievements/icons/placeholder.png");
	else:
		achievement_spr.texture = load("res://assets/images/achievements/AchievementBgLocked.png");
	achievement_spr.position.x = suffix_x;
	achievement_spr.position.y = suffix_y;
	achievement_grp.add_child(achievement_spr);
	
	for i in len(cool_name):
		coolest_point += "?";
		
	shit = coolest_point;

extends Node2D

@onready var achievementsGrp = $achievements;
@onready var descriptionText = $description_stuff/description_text;

var cur_Achievement = 0;
var coolOffset = 145;
var offSetShit = 0;

var achievements_list = [];
var achievements_sorted_list = [];

var achievements_row = 5;
var achievements_col = 5;

var achievementName = Alphabet.new();

func _ready():
	for i in Achievements.achievements.keys():
		if i != "version":
			if !Achievements.get_achievement_info(i)["achievement_hide"]:
				achievements_sorted_list.append([i, Achievements.get_achievement_info(i)["achievement_index"]]);
				
	achievements_sorted_list.sort_custom(func(a, b): return a[1] < b[1]);
	
	for i in achievements_sorted_list:
		achievements_list.append(i[0]);
		
	var id = 0;
	for i in achievements_list:
		if !Achievements.get_achievement_info(i)["achievement_hide"]:
			var new_achievement = Achievements_icon.new();
			new_achievement.cool_name = i;
			new_achievement.achievement_ID = id;
			new_achievement.position.x = 250;
			
			var row = (achievements_list.find(i) % achievements_row)*160;
			var col = floor(achievements_list.find(i) / achievements_row)*160;
			
			new_achievement.global_position += Vector2(row, col);
			achievementsGrp.add_child(new_achievement);
			
			offSetShit += coolOffset;
			id += 1;
			
	achievementName.scale = Vector2(0.55, 0.55);
	achievementName.position = Vector2(20, 610);
	$description_stuff.add_child(achievementName);
	
	change_achievement(0);
	
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && Global.can_use_menus:
			if ev.keycode in [Global.get_key("escape")] && !ev.echo:
				Global.cur_thing = 0;
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
			if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo:
				seeingAchievementStatus = !seeingAchievementStatus;
				
			if ev.keycode in [Global.get_key("ui_down")] && !ev.echo:
				change_achievement(1*achievements_row);
				
			if ev.keycode in [Global.get_key("ui_up")] && !ev.echo:
				change_achievement(-1*achievements_row);
				
			if ev.keycode in [Global.get_key("ui_left")] && !ev.echo:
				change_achievement(-1);
				
			if ev.keycode in [Global.get_key("ui_right")] && !ev.echo:
				change_achievement(1);
				
func change_achievement(change):
	cur_Achievement += change;
	
	Sound.playAudio("scrollMenu", false);
	
	var cur_col = cur_Achievement - (floor(cur_Achievement / achievements_row) * achievements_row);
	if cur_Achievement >= len(achievements_list):
		cur_Achievement = cur_col;
		
	if cur_Achievement < 0:
		cur_Achievement += ceil(achievements_list.size() / achievements_row)*achievements_row;
		
	Global.cur_thing = cur_Achievement;
	
	update_achievement();
	
var achievement_name = "";
var achievement_value = false;

var seeingAchievementStatus = false;
func _process(delta):
	var cur_col = -floor(cur_Achievement / achievements_row) * 160;
	achievementsGrp.position.y = lerp(float(achievementsGrp.position.y)+90, float(cur_col), 0.25)
	
	for j in achievements_list.size():
		achievementsGrp.get_child(j).scale = lerp(achievementsGrp.get_child(j).scale, Vector2(1.20, 1.20) if j == cur_Achievement else Vector2(1, 1), 0.60);
		
	for i in achievementsGrp.get_children():
		if mouse_inside(i.achievement_spr):
			cur_Achievement = i.achievement_ID;
			update_achievement();
			if Input.is_action_just_pressed("mouse_click"):
				seeingAchievementStatus = !seeingAchievementStatus;
				
	if seeingAchievementStatus:
		$description_stuff.position.y = lerp(float($description_stuff.position.y), 0.0, 0.25);
		#$esc_text.position.y = lerp(float($esc_text.position.y), 15.0, 0.25);
	else:
		$description_stuff.position.y = lerp(float($description_stuff.position.y), 165.0, 0.25);
		#$esc_text.position.y = lerp(float($esc_text.position.y), -55.0, 0.25);
		
func mouse_inside(spr):
	var mouse = get_global_mouse_position();
	var size = spr.get_texture().get_size() * spr.scale;
	if mouse.x > spr.global_position.x - size.x / 2 && mouse.x < spr.global_position.x + size.x / 2 && mouse.y > spr.global_position.y - size.y / 2 && mouse.y < spr.global_position.y + size.y / 2:
		return true;
		
	return false;
	
var suffix = "";
func update_achievement():
	if typeof(Achievements.get_achievement_info(achievements_list[cur_Achievement])["achievement_value"]) == TYPE_ARRAY:
		var achievementValue = int(Achievements.get_achievement_info(achievements_list[cur_Achievement])["achievement_value"][0]);
		var achievementMaxValue = int(Achievements.get_achievement_info(achievements_list[cur_Achievement])["achievement_value"][1]);
		suffix = str(achievementValue, " / ", achievementMaxValue);
	else:
		suffix = "";
		
	descriptionText.text = str(Achievements.get_achievement_info(achievements_list[cur_Achievement])["achievement_description"], " ", suffix);
	
	achievementName._creat_word('');
	
	achievement_value = achievementsGrp.get_child(cur_Achievement).cool_value;
	achievement_name = achievementsGrp.get_child(cur_Achievement).cool_name if achievement_value else achievementsGrp.get_child(cur_Achievement).fake_name;
	
	for j in achievements_list.size():
		achievementsGrp.get_child(j).modulate.a = 1 if j == cur_Achievement else 0.50;
		achievementName._creat_word(achievement_name);
		

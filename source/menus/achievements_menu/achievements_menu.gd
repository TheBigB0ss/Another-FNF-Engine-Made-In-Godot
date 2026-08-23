extends Node2D

@onready var achievementsGrp = $achievements;
@onready var descriptionText = $description_stuff/description_text;
@onready var progressBar = $description_stuff/progressBar;
@onready var progressText = $description_stuff/progressText;
@onready var description_stuff = $description_stuff;

var cur_Achievement = 0;
var coolOffset = 145;
var offSetShit = 0;

var achievements_list = [];
var achievements_sorted_list = [];

var achievements_row = 5;
var achievements_col = 5;

var achievementName = Alphabet.new();

func _ready():
	progressBar.max_value = 100;
	
	for i in Achievements.achievements.keys():
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
			achievementsGrp.add_child(new_achievement);
			
			offSetShit += coolOffset;
			id += 1;
			
	for i in achievements_list.size():
		var row = (i % achievements_row);
		var col = (i / achievements_row);
		
		achievementsGrp.get_child(i).global_position += Vector2(row*160, col*160);
		
	achievementName.scale = Vector2(0.5, 0.5);
	achievementName.position = Vector2(20, 610);
	$description_stuff.add_child(achievementName);
	
	progressBar.value = Achievements.progress;
	progressText.text = str("achievement progress:                        ", Achievements.progress, "%");
	
	change_achievement(Global.current_selected["achievements"]);
	
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && Global.can_use_menus:
			if ev.keycode in [GlobalOptions.get_key("escape")] && !ev.echo:
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
			if (ev.keycode in [GlobalOptions.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo:
				seeingAchievementStatus = !seeingAchievementStatus;
				
			if ev.keycode in [GlobalOptions.get_key("ui_down")] && !ev.echo:
				change_achievement(1*achievements_row);
				
			if ev.keycode in [GlobalOptions.get_key("ui_up")] && !ev.echo:
				change_achievement(-1*achievements_row);
				
			if ev.keycode in [GlobalOptions.get_key("ui_left")] && !ev.echo:
				change_achievement(-1);
				
			if ev.keycode in [GlobalOptions.get_key("ui_right")] && !ev.echo:
				change_achievement(1);
				
func change_achievement(change):
	Sound.playAudio("scrollMenu", false);
	
	var row = (cur_Achievement / achievements_row);
	var col = (cur_Achievement % achievements_row);
	
	match change:
		1:
			if col < achievements_row - 1 && cur_Achievement + 1 < achievements_list.size():
				cur_Achievement += 1;
			else:
				cur_Achievement = row * achievements_row;
		-1:
			if col > 0:
				cur_Achievement -= 1;
			else:
				cur_Achievement = min((row + 1) * achievements_row, achievements_list.size()) - 1;
		5:
			#cur_Achievement += achievements_row;
			#if cur_Achievement >= achievements_list.size():
				#cur_Achievement = col;
				
			if (cur_Achievement + achievements_row) < achievements_list.size():
				cur_Achievement = cur_Achievement + achievements_row;
		-5:
			cur_Achievement -= achievements_row;
			if cur_Achievement < 0:
				cur_Achievement = int(ceil(float(achievements_list.size()) / achievements_row)) - 1 * achievements_row + col;
		_:
			cur_Achievement = change;
			
	Global.currentAchievements = cur_Achievement;
	update_achievement();
	
var achievement_name = "";
var achievement_value = false;

var seeingAchievementStatus = false;
func _process(delta):
	achievementsGrp.position.y = lerp(achievementsGrp.position.y, -(cur_Achievement / achievements_row) * 160.0 + 160.0, 1.0 - exp(-8.0 * delta));
	description_stuff.position.y = lerp(description_stuff.position.y, -35.0 if seeingAchievementStatus else 165.0, 1.0 - exp(-8.0 * delta));
	
	for j in achievements_list.size():
		achievementsGrp.get_child(j).scale = lerp(achievementsGrp.get_child(j).scale, Vector2(1.20, 1.20) if j == cur_Achievement else Vector2(1, 1), 1.0 - exp(-10.0 * delta));
		
	#for i in achievementsGrp.get_children():
		#if mouse_inside(i.achievement_spr):
			#cur_Achievement = i.achievement_ID;
			#update_achievement();
			
			#if Input.is_action_just_pressed("mouse_click"):
				#seeingAchievementStatus = !seeingAchievementStatus;
				
#func mouse_inside(spr):
	#var mouse = get_global_mouse_position();
	#var size = spr.get_texture().get_size() * spr.scale;
	#if mouse.x > spr.global_position.x - size.x / 2 && mouse.x < spr.global_position.x + size.x / 2 && mouse.y > spr.global_position.y - size.y / 2 && mouse.y < spr.global_position.y + size.y / 2:
		#return true;
		
	#return false;
	
func update_achievement():
	var suffix = "";
	
	if typeof(Achievements.get_achievement_info(achievements_list[cur_Achievement])["achievement_value"]) == TYPE_ARRAY:
		var achievementValue = int(Achievements.get_achievement_info(achievements_list[cur_Achievement])["achievement_value"][0]);
		var achievementMaxValue = int(Achievements.get_achievement_info(achievements_list[cur_Achievement])["achievement_value"][1]);
		suffix = str(achievementValue, " / ", achievementMaxValue);
		
	descriptionText.text = str(Achievements.get_achievement_info(achievements_list[cur_Achievement])["achievement_description"], " ", suffix);
	
	achievementName._creat_word('');
	
	achievement_value = achievementsGrp.get_child(cur_Achievement).cool_value;
	achievement_name = achievementsGrp.get_child(cur_Achievement).cool_name if achievement_value else achievementsGrp.get_child(cur_Achievement).fake_name;
	
	for j in achievements_list.size():
		achievementsGrp.get_child(j).modulate.a = 1 if j == cur_Achievement else 0.50;
		achievementName._creat_word(achievement_name);
		

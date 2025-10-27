extends CanvasLayer

var timer = Timer.new();

var achievements_fuck = [];
var achievement_show = false;
var final_achievement = false;

func _ready():
	timer.wait_time = 3.5;
	timer.process_mode = Node.PROCESS_MODE_ALWAYS;
	add_child(timer);
	timer.connect("timeout", hide_achievement);
	
func set_achievement(achievement, final_shit):
	achievement_show = true;
	final_achievement = final_shit;
	
	match typeof(Achievements.get_achievement_info(achievement)["achievement_value"]):
		TYPE_BOOL:
			if !Achievements.get_achievement_info(achievement)["achievement_value"]:
				achievements_fuck.append(achievement);
				show_achievement(achievements_fuck[0]);
				
		TYPE_ARRAY:
			if !Achievements.get_achievement_info(achievement)["achievement_value"][2]:
				achievements_fuck.append(achievement);
				show_achievement(achievements_fuck[0]);
				
	print(achievements_fuck);
	
func show_achievement(achievement):
	timer.start();
	
	create_box(achievement);
	
	var tween = get_tree().create_tween();
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property($'Control', "position:y", -160, 0.68).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN);
	
	Achievements.unlock_achievement(achievement);
	
func hide_achievement():
	var tween = get_tree().create_tween();
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property($'Control', "position:y", 140, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN);
	tween.tween_callback(Callable(self, "delete_shit"));
	
func delete_shit():
	timer.stop();
	achievement_show = false;
	
	for i in $Control.get_children():
		$Control.remove_child(i);
		i.queue_free();
		
	achievements_fuck.remove_at(0);
	if achievements_fuck.size() > 0:
		show_achievement(achievements_fuck[0]);
		
	if final_achievement:
		if achievements_fuck.size() == 0:
			Achievements.emit_signal("end_achievement");
			
func create_box(achievement):
	var font:FontFile = load("res://assets/fonts/vcr.ttf");
	
	var popUp = ColorRect.new();
	popUp.size = Vector2(375, 135);
	popUp.position = Vector2(430, 735);
	popUp.color = Color.BLACK
	$Control.add_child(popUp);
	
	var achievementIcon = Sprite2D.new();
	achievementIcon.texture = load("res://assets/images/achievements/icons/%s.png"%[Achievements.get_achievement_info(achievement)["achievement_name"]]);
	achievementIcon.position = Vector2(525, 805);
	$Control.add_child(achievementIcon);
	
	var achievementText = Label.new();
	achievementText.text = Achievements.get_achievement_info(achievement)["achievement_name"];
	achievementText.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT;
	achievementText.position = Vector2(590, 765);
	achievementText.add_theme_font_override("font", font);
	achievementText.add_theme_color_override("font_shadow_color", Color.BLACK);
	achievementText.add_theme_font_size_override("font_size", 20);
	achievementText.modulate = Color("#ffffff");
	$Control.add_child(achievementText);
	
	var achievementDescriptionText = Label.new();
	achievementDescriptionText.text = Achievements.get_achievement_info(achievement)["achievement_description"];
	achievementDescriptionText.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT;
	achievementDescriptionText.position = Vector2(590, 810);
	achievementDescriptionText.add_theme_font_override("font", font);
	achievementDescriptionText.add_theme_color_override("font_shadow_color", Color.BLACK);
	achievementDescriptionText.add_theme_font_size_override("font_size", 20);
	achievementDescriptionText.modulate = Color("#ffffff");
	$Control.add_child(achievementDescriptionText);
	
	var name_size = font.get_string_size(achievementText.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20);
	var desc_size = font.get_string_size(achievementDescriptionText.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20);

	var total_width = max(name_size.x, desc_size.x);
	if total_width > popUp.size.x - 200:
		popUp.size.x = total_width + 220;

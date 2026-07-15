extends CanvasLayer

var achievements_fuck = [];
var achievement_show = false;
var final_achievement = false;

func set_achievement(achievement, final_shit):
	final_achievement = final_shit;
	
	if Achievements.check_achievement_status(achievement):
		return;
		
	achievements_fuck.append(achievement);
	
	if !achievement_show:
		achievement_show = true;
		show_achievement(achievements_fuck[0]);
		
func show_achievement(achievement):
	set_timer(4);
	
	Sound.add_new_sound("confirmMenu");
	create_box(achievement);
	
	$Control.position.y = 140;
	
	var tween = create_tween();
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property($Control, "position:y", -175, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT);
	tween.tween_property($Control, "position:y", -160, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT);
	
	Achievements.unlock_achievement(achievement);
	
func hide_achievement():
	var tween = create_tween();
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property($Control, "position:y", 170, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN);
	tween.tween_callback(delete_shit);
	
func delete_shit():
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
	var padding = 20.0;
	var icon_size = 65.0;
	var spacing = 20.0;
	
	var font:FontFile = load("res://assets/fonts/vcr.ttf");
	
	var popUp = ColorRect.new();
	popUp.position = Vector2(420, 735);
	popUp.size = Vector2(375, 135);
	popUp.color = Color.BLACK
	$Control.add_child(popUp);
	
	var achievementIcon = Sprite2D.new();
	achievementIcon.texture = load("res://assets/images/achievements/icons/%s.png"%[Achievements.get_achievement_info(achievement)["achievement_name"]]);
	achievementIcon.position = popUp.position + Vector2((padding + icon_size / 2)+25, popUp.size.y / 2);
	$Control.add_child(achievementIcon);
	
	var achievementText = Label.new();
	achievementText.text = Achievements.get_achievement_info(achievement)["achievement_name"];
	achievementText.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT;
	achievementText.position = popUp.position + Vector2((padding + icon_size + spacing)+50, 25);
	achievementText.add_theme_font_override("font", font);
	achievementText.add_theme_color_override("font_shadow_color", Color.BLACK);
	achievementText.add_theme_font_size_override("font_size", 20);
	achievementText.modulate = Color("#ffffff");
	$Control.add_child(achievementText);
	
	var achievementDescriptionText = Label.new();
	achievementDescriptionText.text = Achievements.get_achievement_info(achievement)["achievement_description"];
	achievementDescriptionText.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT;
	achievementDescriptionText.position = popUp.position + Vector2((padding + icon_size + spacing)+50, 65);
	achievementDescriptionText.add_theme_font_override("font", font);
	achievementDescriptionText.add_theme_color_override("font_shadow_color", Color.BLACK);
	achievementDescriptionText.add_theme_font_size_override("font_size", 20);
	achievementDescriptionText.modulate = Color("#ffffff");
	$Control.add_child(achievementDescriptionText);
	
	var name_size = font.get_string_size(Achievements.get_achievement_info(achievement)["achievement_name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 20);
	var desc_size = font.get_string_size(Achievements.get_achievement_info(achievement)["achievement_description"], HORIZONTAL_ALIGNMENT_LEFT, -1, 20);
	
	var text_width = max(name_size.x, desc_size.x);
	var popup_width = (icon_size + spacing + text_width + padding * 2)+40;
	popUp.size.x = max(375, popup_width);
	
func set_timer(time):
	var elapsed = 0.0;
	
	while elapsed < time:
		await get_tree().create_timer(0.15).timeout;
		elapsed += 0.15;
		
	hide_achievement();

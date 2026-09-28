extends Node2D

@onready var characterGrp = $"character";
@onready var characters_options = $"offset_layer/TabContainer/main settings/characters";
@onready var cur_anim_text = $"offset_layer/TabContainer/anim settings/current_anim";
@onready var cur_frame_text = $"offset_layer/TabContainer/anim settings/current_frame";
@onready var pos_cross = $cross;

@onready var frame_slider = $"offset_layer/TabContainer/anim settings/frames_ui/AnimationSlider";

@onready var camera = $Camera2D;

@onready var ratingSpr = $rating_layer/rating;
@onready var comboSpr = $rating_layer/combo;
@onready var numsSpr = $rating_layer/nums;

@onready var charIcon = $offset_layer/Icon;
@onready var animationLabel = $offset_layer/animations;
@onready var charBarColor = $offset_layer/colorBar;

var cur_pose = 0;
var character_list = [];
var offset_array = [];

var characterJson = {};
var characterData = [];
var offset_count = 0;

var charScale = Vector2.ONE;

func _ready():
	SongData.isOnDeathScreen = false;
	
	Discord.update_discord_info("offset menu", "Is in menus");
	
	MusicManager._play_song(GlobalOptions.updated_pause_music, "music", true);
	
	frame_slider.value_changed.connect(change_character_frame);
	
	for i in addCharToList():
		if i.contains(".json"):
			i = i.replace(".json", "");
			
		if i == "none":
			continue;
			
		character_list.append(i);
		characters_options.add_item(i);
		
	characters_options.connect("item_selected",change_character);
	
	ratingSpr.position = Vector2(GlobalOptions.ratings_positions["rating"][0], GlobalOptions.ratings_positions["rating"][1]);
	comboSpr.position = Vector2(GlobalOptions.ratings_positions["combo"][0], GlobalOptions.ratings_positions["combo"][1]);
	numsSpr.position = Vector2(GlobalOptions.ratings_positions["nums"][0], GlobalOptions.ratings_positions["nums"][1]);
	
	characters_options.select(0 if !SongData.isPlaying else character_list.find(SongData.characters["opponent"]));
	
	setup_rating_mode();
	change_character();
	play_anim();
	
var adjusting_rating = false;
func get_char_json(character):
	character = character.trim_suffix(".tscn");
	
	var path = "res://assets/data/characters/%s.json"%[character];
	var file = FileAccess.open(path, FileAccess.READ);
	var data = JSON.parse_string(file.get_as_text());
	return data.get("Poses", []);
	
func setup_rating_mode():
	if GlobalOptions.rating_mode == "hud element":
		for element in [ratingSpr, comboSpr, numsSpr]:
			element.reparent($rating_layer, true);
			
	elif GlobalOptions.rating_mode == "game element":
		for element in [ratingSpr, comboSpr, numsSpr]:
			element.reparent($rating_node, true);
			
func change_character(_char = 0):
	for i in characterGrp.get_children():
		i.queue_free();
		
	cur_pose = 0;
	offset_count = 0;
	
	offset_array.clear();
	characterData.clear();
	characterJson.clear();
	
	var character_name = character_list[characters_options.selected];
	
	var character = load("res://source/characters/characters_scenes/%s.tscn"%[character_name]).instantiate()
	characterGrp.add_child(character);
	
	var poses = get_char_json(character_name);
	
	for i in characterGrp.get_children():
		%color_text.color = Color(i.charData["HealthBarColor"]).to_html();
		
		%icon_text.text = i.curIcon;
		%x_scale.value = i.charData["scale"][0];
		%y_scale.value = i.charData["scale"][1];
		%camera_X.value = i.charData["cameraPos"][0];
		%camera_Y.value = i.charData["cameraPos"][1];
		
		%flipX.button_pressed = i.charData["FlipX"];
		%flipY.button_pressed = i.charData["FlipY"];
		%is_player.button_pressed = i.charData["isPlayer"];
		%anim_time.value = i.anim_time;
		%cam_follow_poses.button_pressed = i.cam_follow_pos;
		%animType.selected = i.anim_type - 1;
		
		update_cross(i.charData["cameraPos"][0], i.charData["cameraPos"][1])
		update_scale_value(i.charData["scale"][0], i.charData["scale"][1]);
		flip_char(i.charData["FlipX"], i.charData["FlipY"]);
		
		while offset_count < character.animList.size():
			var pose = {};
			
			if offset_count < poses.size():
				pose = poses[offset_count];
				
			var offset = pose.get("Offset", [0, 0]);
			
			var anim_time = pose.get("Anim Time", 5);
			var anim_beat = pose.get("anim beat", 2);
			var special_anim = pose.get("special anim", false);
			
			offset_array.append(offset.duplicate());
			animTimes.append(anim_time);
			animBeats.append(anim_beat);
			specialAnims.append(special_anim);
			
			characterData.append({
				"Name": character.posesList[offset_count],
				"Anim": character.animList[offset_count],
				"Offset": offset.duplicate(),
				"anim beat": anim_beat,
				"Anim Time": anim_time,
				"special anim": special_anim
			});
			
			offset_count += 1;
			
	change_anim(0);
	set_rating_pos();
	update_anim_label();
	
func update_offset_value(x = 0, y = 0):
	for i in characterGrp.get_children():
		if i.character is AnimatedSprite2D or i.character is SparrowCharacter or i.character is DeadSparrowCharacter:
			i.character.offset = Vector2.ZERO;
			i.character.offset = Vector2(x, y);
			
		if i.character is Sprite2D or i.character is AtlasCharacter or i.character is DeadAtlasCharacter:
			i.character.position = i.base_position + Vector2(x, y);
			
	update_anim_label();
	
func update_cross(x, y):
	var midpoint = characterGrp.get_child(0).global_position;
	$cross_position.position = Vector2(midpoint.x + x, midpoint.y + y);
	pos_cross.position = $cross_position.position - pos_cross.texture.get_size() * 0.5 * pos_cross.scale;
	
	%camera_X.value = x;
	%camera_Y.value = y;
	
func update_scale_value(x = 1, y = 1):
	for i in characterGrp.get_children():
		i.character.scale.x = x;
		i.character.scale.y = y;
		
	charScale = Vector2(%x_scale.value, %y_scale.value);
	%x_scale.value = x;
	%y_scale.value = y;
	
func flip_char(flipX, flipY):
	for i in characterGrp.get_children():
		i.character.flip_h = flipX;
		i.character.flip_v = flipY;
		
func play_anim():
	for i in characterGrp.get_children():
		if i.character is Sprite2D:
			i.character_anim.play(i.posesList[cur_pose]);
			
		elif i.character is AnimatedSprite2D or i.character is AtlasCharacter or i.character is SparrowCharacter or i.character is DeadSparrowCharacter or i.character is DeadAtlasCharacter:
			i.character.play(i.posesList[cur_pose]);
			
func set_rating_pos():
	if adjusting_rating:
		$rating_layer.show();
		$rating_node.show();
		$offset_layer.hide();
		$character.hide();
		$cross.hide();
		
		%rating_x.value = GlobalOptions.ratings_positions["rating"][0];
		%rating_y.value = GlobalOptions.ratings_positions["rating"][1];
		
		%combo_x.value = GlobalOptions.ratings_positions["combo"][0];
		%combo_y.value = GlobalOptions.ratings_positions["combo"][1];
		
		%nums_x.value = GlobalOptions.ratings_positions["nums"][0];
		%nums_y.value = GlobalOptions.ratings_positions["nums"][1];
	else:
		$rating_layer.hide();
		$rating_node.hide();
		$offset_layer.show();
		$character.show();
		$cross.show();
		
func mouse_inside(spr):
	var size = spr.texture.get_size() * spr.scale
	var mouse = spr.get_global_mouse_position();
	if mouse.x > spr.global_position.x - size.x / 2 && mouse.x < spr.global_position.x + size.x / 2 && mouse.y > spr.global_position.y - size.y / 2 && mouse.y < spr.global_position.y + size.y / 2:
		return true;
		
	return false;
	
var char_scale = Vector2.ZERO;
func mouse_inside_character(spr):
	var mouse = get_global_mouse_position();
	var rect = Rect2();
	
	if spr is AnimatedSprite2D:
		var size = spr.sprite_frames.get_frame_texture(spr.animation, spr.frame).get_size() * spr.scale;
		rect = Rect2(spr.global_position - size / 2.0, size);
		char_scale = spr.scale;
		
		return rect.has_point(mouse);
		
	elif spr is Sprite2D:
		var size = spr.get_texture().get_size() * spr.scale;
		rect = Rect2(spr.global_position - size / 2.0, size);
		char_scale = spr.scale;
		
		return rect.has_point(mouse);
		
	elif spr is SparrowCharacter or spr is DeadSparrowCharacter:
		rect = spr.get_rect();
		char_scale = abs(spr.scale);
		
		return rect.has_point(mouse);
		
	elif spr is AtlasCharacter or spr is DeadAtlasCharacter:
		rect = spr.get_rect();
		char_scale = abs(spr.scale);
		
		return rect.has_point(spr.to_local(mouse));
		
	return false;
	
var pos_change_value = 0;

const CAM_KEYS = {
	KEY_W: Vector2(0, -20),
	KEY_S: Vector2(0, 20),
	KEY_A: Vector2(-20, 0),
	KEY_D: Vector2(20, 0)
};

func _input(ev):
	if !(ev is InputEventKey):
		return;
		
	if !ev.pressed:
		return;
		
	if ev.echo:
		if ev.keycode && CAM_KEYS.has(ev.keycode):
			camera.offset += CAM_KEYS[ev.keycode];
			
		return;
		
	match ev.keycode:
		KEY_TAB:
			adjusting_rating = !adjusting_rating;
			set_rating_pos();
		KEY_ESCAPE:
			Global.update_cursor("default");
			if !SongData.isPlaying:
				MusicManager._play_song("freakyMenu", "music", true);
				Global.changeScene("menus/main_menu/MainMenu", true, false);
			else:
				Global.changeScene("gameplay/PlayState", true, false);
				
	if !adjusting_rating:
		match ev.keycode:
			KEY_E:
				change_anim(1);
			KEY_Q:
				change_anim(-1);
			KEY_SPACE:
				play_anim();
			KEY_RIGHT:
				offset_array[cur_pose][0] += pos_change_value;
				update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
			KEY_LEFT:
				offset_array[cur_pose][0] -= pos_change_value;
				update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
			KEY_DOWN:
				offset_array[cur_pose][1] += pos_change_value;
				update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
			KEY_UP:
				offset_array[cur_pose][1] -= pos_change_value;
				update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
				
	if ev.alt_pressed:
		match ev.keycode:
			KEY_RIGHT:
				charScale.x += 1;
			KEY_LEFT:
				charScale.x -= 1;
			KEY_UP:
				charScale.y += 1;
			KEY_DOWN:
				charScale.y -= 1;
				
		return;
		
func change_anim(change):
	if offset_array != []:
		cur_pose += change;
		cur_pose = wrapi(cur_pose, 0, offset_array.size());
		
		for i in characterGrp.get_children():
			cur_anim_text.text = "animation: %s"%[i.animList[cur_pose]];
			update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
			play_anim();
			
func change_character_frame(frame):
	var value = clamp(frame, 0.0, float(frame_slider.newMaxVal));
	
	var character_data = characterGrp.get_child(0);
	var character = character_data.character;
	
	if character is Sprite2D:
		character_data.character_anim.pause();
		var anim = character_data.character_anim.get_animation(character_data.posesList[cur_pose]);
		character_data.character_anim.seek(value * anim.step, true);
		
	elif character is AnimatedSprite2D:
		character.stop();
		character.frame = int(value);
		
	elif character is SparrowCharacter or character is DeadSparrowCharacter:
		character.playing = false;
		character.frame = int(value);
		character.queue_redraw();
		
	elif character is AtlasSprite or character is DeadAtlasCharacter:
		character.playing = false;
		character.timer = character.start_frame + value;
		character.frame = int(character.timer);
		
var rating_status = null;
enum RatingState {
	RATING = 0,
	COMBO = 1,
	NUMS = 2
};

var dragging_character = false;

var animTimes = [];
var animBeats = [];
var specialAnims = [];

var last_icon = "";
var new_icon = "";
func _process(_delta: float) -> void:
	last_icon = new_icon;
	
	if last_icon != %icon_text.text:
		new_icon = %icon_text.text;
		charIcon.reload_icon(new_icon);
		
	charBarColor.tint_under = %color_text.color;
	
	update_scale_value(charScale.x, charScale.y);
	update_character_frame();
	
	pos_change_value = 1 if !Input.is_action_pressed("ui_shift") else 10;
	
	var character_data = characterGrp.get_child(0);
	if Input.is_action_pressed("mouse_click") && !$FileDialog.visible:
		if Input.is_action_pressed("ui_shift"):
			var mouse = get_global_mouse_position();
			var character_pos = character_data.global_position;
			
			update_cross(mouse.x - character_pos.x, mouse.y - character_pos.y);
			
			return;
			
		if Input.is_action_just_pressed("mouse_click") && mouse_inside_character(character_data.character):
			dragging_character = true;
			
	if Input.is_action_just_released("mouse_click"):
		dragging_character = false;
		
	if dragging_character && !$FileDialog.visible:
		var mouse = characterGrp.to_local(get_global_mouse_position());
		
		%x_offset.value = mouse.x / char_scale.x;
		%y_offset.value = mouse.y / char_scale.y;
		
		return;
		
	if adjusting_rating:
		var mouse = get_viewport().get_mouse_position();
		
		if Input.is_action_just_pressed("mouse_click"):
			if mouse_inside(comboSpr):
				rating_status = RatingState.COMBO;
			elif mouse_inside(numsSpr):
				rating_status = RatingState.NUMS;
			elif mouse_inside(ratingSpr):
				rating_status = RatingState.RATING;
				
		elif Input.is_action_pressed("mouse_click") && rating_status != null:
			match rating_status:
				RatingState.COMBO:
					%combo_x.value = mouse.x;
					%combo_y.value = mouse.y;
					
				RatingState.NUMS:
					%nums_x.value = mouse.x;
					%nums_y.value = mouse.y;
					
				RatingState.RATING:
					%rating_x.value = mouse.x;
					%rating_y.value = mouse.y;
					
		elif Input.is_action_just_released("mouse_click"):
			rating_status = null;
			
		ratingSpr.position = Vector2(%rating_x.value, %rating_y.value);
		comboSpr.position = Vector2(%combo_x.value, %combo_y.value);
		numsSpr.position = Vector2(%nums_x.value, %nums_y.value);
		
		ratingSpr.visible = %visible_rating.button_pressed;
		comboSpr.visible = %visible_combo.button_pressed;
		numsSpr.visible = %visible_nums.button_pressed;
		
		GlobalOptions.set_setting("rating_pos", "meta", [%rating_x.value, %rating_y.value, %visible_rating.button_pressed]);
		GlobalOptions.set_setting("combo_pos", "meta", [%combo_x.value, %combo_y.value, %visible_combo.button_pressed]);
		GlobalOptions.set_setting("nums_pos", "meta", [%nums_x.value, %nums_y.value, %visible_nums.button_pressed]);
		
	if !$FileDialog.visible:
		if Input.is_action_just_released("mouse_wheel_down"):
			change_zoom(-0.05);
		if Input.is_action_just_released("mouse_wheel_up"):
			change_zoom(0.05);
			
	Global.update_cursor("pointer" if get_viewport().gui_get_hovered_control() is TabBar or get_viewport().gui_get_hovered_control() is SpinBox or get_viewport().gui_get_hovered_control() is CheckBox or get_viewport().gui_get_hovered_control() is Button or get_viewport().gui_get_hovered_control() is OptionButton else "default");
	
	%x_offset.value = offset_array[cur_pose][0];
	%y_offset.value = offset_array[cur_pose][1];
	%beat_time.value = animBeats[cur_pose];
	%anim_time.value = animTimes[cur_pose];
	%is_special.button_pressed = specialAnims[cur_pose];
	
func update_character_frame():
	var frame = 0;
	var total_frames = 0;
	
	if offset_array.is_empty():
		return;
		
	var character_data = characterGrp.get_child(0);
	var character = character_data.character;
	
	if character is AnimatedSprite2D:
		frame = character.frame;
		total_frames = character.sprite_frames.get_frame_count(character_data.posesList[cur_pose]);
		
	elif character is AtlasCharacter or character is DeadAtlasCharacter:
		frame = int(character.frame - character.start_frame);
		total_frames = int(abs(character.start_frame - character.limit) + 1);
		
	elif character is SparrowCharacter or character is DeadSparrowCharacter:
		frame = int(character.frame);
		total_frames = int(character.get_anim_length(character_data.posesList[cur_pose]));
		
	elif character is Sprite2D:
		var animation = character_data.character_anim.get_animation(character_data.posesList[cur_pose]);
		
		frame = int(round(character_data.character_anim.current_animation_position / animation.step));
		total_frames = int(round(animation.length / animation.step)) + 1;
		
	if total_frames <= 0:
		return;
		
	frame = clamp(frame, 0, total_frames - 1);
	
	cur_frame_text.text = "frame: %d / %d" % [frame + 1, total_frames];
	
	frame_slider.value = frame;
	frame_slider.newMaxVal = total_frames-1;
	
func update_anim_label():
	animationLabel.text = "";
	if offset_array.is_empty():
		return;
		
	for i in characterGrp.get_children():
		for j in i.animList.size():
			if j >= offset_array.size():
				continue;
				
			animationLabel.text += "%s: (%s, %s)\n" % [i.animList[j], offset_array[j][0], offset_array[j][1]];
			
func change_zoom(val):
	var last = get_global_mouse_position();
	camera.zoom += Vector2.ONE * val;
	
	var current = get_global_mouse_position();
	camera.position += last-current;
	
func addCharToList():
	var charList = [];
	for i in Global.get_folder("assets/data/characters/"):
		if i == "none.json":
			continue;
			
		if i.ends_with(".json"):
			charList.append(i);
			
	return charList;
	
func save_file() -> void:
	$FileDialog.popup_centered();
	
func _on_file_dialog_file_selected(json):
	characterJson = {
		"Poses": characterData,
		"HealthBarColor": str("#", %color_text.color.to_html()),
		"HealthIcon": %icon_text.text,
		"FlipX": %flipX.button_pressed,
		"FlipY": %flipY.button_pressed,
		"isPlayer": %is_player.button_pressed,
		"AnimatedIcon": %animated_icon.button_pressed,
		"scale": [%x_scale.value, %y_scale.value],
		"cameraPos": [%camera_X.value, %camera_Y.value],
		"camera follow pos": %cam_follow_poses.button_pressed,
		"anim type": [1, 2, 3][%animType.selected]
	};
	
	var new_jsonFile = FileAccess.open(json, FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(characterJson, "\t"));
	new_jsonFile.close();
	print(characterJson)
	print('save: ', json);
	
func _on_x_scale_value_changed(value: float) -> void:
	update_scale_value(value, %y_scale.value);
	
func _on_y_scale_value_changed(value: float) -> void:
	update_scale_value(%x_scale.value, value);
	
func _on_flip_x_pressed() -> void:
	flip_char(%flipX.button_pressed, %flipY.button_pressed);
	
func _on_flip_y_pressed() -> void:
	flip_char(%flipX.button_pressed, %flipY.button_pressed);
	
func _on_camera_x_value_changed(value: float) -> void:
	update_cross(value, %camera_Y.value);
	
func _on_camera_y_value_changed(value: float) -> void:
	update_cross(%camera_X.value, value);
	
func _on_y_offset_value_changed(value: float) -> void:
	if offset_array.is_empty():
		return;
		
	offset_array[cur_pose][1] = value;
	update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
	
func _on_x_offset_value_changed(value: float) -> void:
	if offset_array.is_empty():
		return;
		
	offset_array[cur_pose][0] = value;
	update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
	
func _on_anim_time_value_changed(value: float) -> void:
	if animTimes.is_empty():
		return;
		
	animTimes[cur_pose] = value;
	
func _on_beat_time_value_changed(value: float) -> void:
	if animBeats.is_empty():
		return;
		
	animBeats[cur_pose] = value;
	
func _on_color_button_pressed() -> void:
	%color_text.color = charIcon.get_icon_color();
	charBarColor.tint_under = %color_text.color;

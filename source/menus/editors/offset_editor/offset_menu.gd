extends Node2D

@onready var characterGrp = $"character";
@onready var characters_options = $"offset_layer/TabContainer/main settings/characters";
@onready var cur_anim_text = $"offset_layer/TabContainer/anim settings/current_anim";
@onready var pos_cross = $cross;
@onready var camera = $Camera2D;

@onready var ratingSpr = $rating_layer/rating;
@onready var comboSpr = $rating_layer/combo;
@onready var numsSpr = $rating_layer/nums;

var cur_pose = 0;
var character_list = [];
var offset_array = [];
var replaced = "";

var characterJson = {};
var characterData = [];
var offset_count = 0;

func _ready():
	Discord.update_discord_info("offset menu", "Is in menus");
	SongData.isOnDeathScreen = false;
	MusicManager._play_music(GlobalOptions.updated_pause_music, false, true);
	
	if GlobalOptions.rating_mode == "hud element":
		for i in [ratingSpr, comboSpr, numsSpr]:
			i.reparent($rating_layer, true);
	elif GlobalOptions.rating_mode == "game element":
		for i in [ratingSpr, comboSpr, numsSpr]:
			i.reparent($rating_node, true);
	
	for i in addCharToList():
		if i.contains(".json"):
			replaced = i.replace(".json", "");
			
		if replaced == "none":
			continue;
			
		character_list.append(replaced);
		characters_options.add_item(replaced);
		
	characters_options.connect("item_selected",change_character);
	
	ratingSpr.position = Vector2(GlobalOptions.ratings_positions["rating"][0], GlobalOptions.ratings_positions["rating"][1]);
	comboSpr.position = Vector2(GlobalOptions.ratings_positions["combo"][0], GlobalOptions.ratings_positions["combo"][1]);
	numsSpr.position = Vector2(GlobalOptions.ratings_positions["nums"][0], GlobalOptions.ratings_positions["nums"][1]);
	
	change_character(0);
	play_anim();
	
var adjusting_rating = false;
func get_char_json(character, cur_offset, option):
	var offset = {};
	
	if character.contains(".tscn"):
		character = character.replace(".tscn", "");
		
	var jsonFile = FileAccess.open("res://assets/data/characters/%s.json"%[character],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	offset = jsonData.get_data();
	jsonFile.close();
	return offset["Poses"][cur_offset][option];
	
func change_character(char):
	for i in characterGrp.get_children():
		characterGrp.remove_child(i);
		i.queue_free();
		
	offset_array = [];
	offset_count = 0;
	cur_pose = 0;
	characterData = [];
	characterJson = {};
	
	var character = load("res://source/characters/%s.tscn"%[character_list[characters_options.selected]]).instantiate();
	characterGrp.add_child(character);
	
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
		
		update_cross(i.charData["cameraPos"][0], i.charData["cameraPos"][1]);
		update_scale_value(i.charData["scale"][0], i.charData["scale"][1]);
		flip_char(i.charData["FlipX"], i.charData["FlipY"]);
		
	set_rating_pos();
	
func update_offset_value(x = 0, y = 0):
	for i in characterGrp.get_children():
		if i.character is AnimatedSprite2D:
			i.character.offset = Vector2.ZERO;
			i.character.offset = Vector2(x, y);
			
		if i.character is Sprite2D:
			i.character.position = i.base_position + Vector2(x, y);
			print(i.character.position)
			
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
		
func flip_char(flipX, flipY):
	for i in characterGrp.get_children():
		i.character.flip_h = flipX;
		i.character.flip_v = flipY;
		
func play_anim():
	for i in characterGrp.get_children():
		if i.character is Sprite2D:
			i.character_anim.play(i.posesList[cur_pose]);
			
		elif i.character is AnimatedSprite2D:
			i.character.play(i.posesList[cur_pose]);
			
var cursor = "";
func update_cursor(new_cursor):
	var path = "res://assets/images/cursors/cursor-%s.png"%[new_cursor];
	Input.set_custom_mouse_cursor(load(path), Input.CURSOR_ARROW, Vector2.ZERO);
	
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
		
func mouse_inside(spr, texture):
	var size = texture.get_size() * spr.scale
	var mouse = spr.get_global_mouse_position();
	if mouse.x > spr.global_position.x - size.x / 2 && mouse.x < spr.global_position.x + size.x / 2 && mouse.y > spr.global_position.y - size.y / 2 && mouse.y < spr.global_position.y + size.y / 2:
		return true;
		
	return false;
	
var char_scale = Vector2.ZERO;
func mouse_inside_character(spr):
	var mouse = get_global_mouse_position();
	var size = null;
	
	if spr is AnimatedSprite2D:
		size = spr.sprite_frames.get_frame_texture(spr.animation, spr.frame).get_size() * spr.scale;
		char_scale = spr.scale;
		
	if spr is Sprite2D:
		size = spr.get_texture().get_size() * spr.scale;
		char_scale = spr.scale;
		
	if mouse.x > spr.global_position.x - size.x / 2 && mouse.x < spr.global_position.x + size.x / 2 && mouse.y > spr.global_position.y - size.y / 2 && mouse.y < spr.global_position.y + size.y / 2:
		return true;
		
	return false;
	
var pos_change_value = 0;
func _input(ev):
	if ev is InputEventMouseMotion:
		update_cursor(cursor);
		
	if ev is InputEventKey:
		if ev.pressed && !ev.echo:
			if ev.keycode in [KEY_TAB]:
				adjusting_rating = !adjusting_rating;
				set_rating_pos();
				
			if ev.keycode in [KEY_ESCAPE]:
				MusicManager._play_music("freakyMenu", true, true);
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
			if !adjusting_rating:
				if ev.keycode in [KEY_E]:
					change_anim(1);
					
				if ev.keycode in [KEY_Q]:
					change_anim(-1);
					
				if ev.keycode in [KEY_SPACE]:
					play_anim();
					
				if ev.keycode in [KEY_RIGHT]:
					offset_array[cur_pose][0] += pos_change_value;
					update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
					
				if ev.keycode in [KEY_LEFT]:
					offset_array[cur_pose][0] -= pos_change_value;
					update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
					
				if ev.keycode in [KEY_DOWN]:
					offset_array[cur_pose][1] += pos_change_value;
					update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
					
				if ev.keycode in [KEY_UP]:
					offset_array[cur_pose][1] -= pos_change_value;
					update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
					
		if ev.pressed:
			if ev.keycode in [KEY_W]:
				camera.offset.y -= 20;
				
			if ev.keycode in [KEY_S]:
				camera.offset.y += 20;
				
			if ev.keycode in [KEY_D]:
				camera.offset.x += 20;
				
			if ev.keycode in [KEY_A]:
				camera.offset.x -= 20;
				
func change_anim(change):
	if offset_array != []:
		cur_pose += change;
		cur_pose = wrapi(cur_pose, 0, offset_array.size());
		
		for i in characterGrp.get_children():
			cur_anim_text.text = "animation: %s"%[i.animList[cur_pose]];
			update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
			play_anim();
			
var holding_char = false;
var rating_status = null;
enum RatingState {
	RATING = 0,
	COMBO = 1,
	NUMS = 2
};

var can_grab = true;

var animTimes = [];
var animBeats = [];
var specialAnims = [];
func _process(delta: float) -> void:
	if adjusting_rating:
		var mouse = get_viewport().get_mouse_position();
		
		if Input.is_action_just_pressed("mouse_click"):
			if mouse_inside(comboSpr, comboSpr.texture):
				rating_status = RatingState.COMBO;
				
			elif mouse_inside(numsSpr, numsSpr.shit_spr.texture):
				rating_status = RatingState.NUMS;
				
			elif mouse_inside(ratingSpr, ratingSpr.texture):
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
		
		GlobalOptions.get_setting("rating_pos", [%rating_x.value, %rating_y.value]);
		GlobalOptions.get_setting("combo_pos", [%combo_x.value, %combo_y.value]);
		GlobalOptions.get_setting("nums_pos", [%nums_x.value, %nums_y.value]);
		
	#elif can_grab && !adjusting_rating:
		#var mouse = characterGrp.to_local(get_global_mouse_position());
		#var mouse_shit = get_viewport().gui_get_hovered_control() is TabBar or get_viewport().gui_get_hovered_control() is SpinBox or get_viewport().gui_get_hovered_control() is CheckBox or get_viewport().gui_get_hovered_control() is Button or get_viewport().gui_get_hovered_control() is OptionButton;
		#var character = null;
		#
		#for i in characterGrp.get_children():
			#character = i.character;
			#
		#if Input.is_action_pressed("mouse_click") && mouse_inside_character(character):
			#holding_char = !$FileDialog.visible;
		#else:
			#holding_char = false;
			#
		#if holding_char:
			#offset_array[cur_pose][0] = mouse.x/char_scale.x;
			#offset_array[cur_pose][1] = mouse.y/char_scale.y;
			
	if !$FileDialog.visible:
		if Input.is_action_pressed("ui_shift") && Input.is_action_pressed("mouse_click"):
			update_cross(get_global_mouse_position().x - characterGrp.get_child(0).global_position.x, get_global_mouse_position().y - characterGrp.get_child(0).global_position.y);
			
		if Input.is_action_just_released("mouse_wheel_down"):
			if camera.zoom.x < 0.50:
				return;
				
			var lastPos = get_global_mouse_position();
			
			camera.zoom.x -= 0.2/4;
			camera.zoom.y -= 0.2/4;
			
			var curPos = get_global_mouse_position();
			camera.position += lastPos - curPos;
			
		if Input.is_action_just_released("mouse_wheel_up"):
			var lastPos = get_global_mouse_position();
			
			camera.zoom.x += 0.2/4;
			camera.zoom.y += 0.2/4;
			
			var curPos = get_global_mouse_position();
			camera.position += lastPos - curPos;
			
	if (Input.is_action_just_released("mouse_click") or !Input.is_action_just_pressed("mouse_click")) && !can_grab:
		can_grab = true;
		
	pos_change_value = 1 if Input.is_action_pressed("ui_shift") else 10;
	
	cursor = "pointer" if get_viewport().gui_get_hovered_control() is TabBar or get_viewport().gui_get_hovered_control() is SpinBox or get_viewport().gui_get_hovered_control() is CheckBox or get_viewport().gui_get_hovered_control() is Button or get_viewport().gui_get_hovered_control() is OptionButton else "default";
	
	for i in characterGrp.get_children():
		if !offset_count > i.animList.size()-1:
			offset_array.append(get_char_json(character_list[characters_options.selected], offset_count, "Offset"));
			animTimes.append(5);
			animBeats.append(2);
			specialAnims.append(false);
			
			characterData.append({
				"Name": i.posesList[offset_count],
				"Anim": i.animList[offset_count],
				"Offset": [0, 0],
				"anim beat": 2,
				"Anim Time": 5,
				"special anim": false
			});
			
			characterData[offset_count]["Offset"] = [
				offset_array[offset_count][0],
				offset_array[offset_count][1]
			];
			
			characterData[offset_count]["anim beat"] = int(animBeats[offset_count]);
			characterData[offset_count]["Anim Time"] = int(animTimes[offset_count]);
			characterData[offset_count]["special anim"] = specialAnims[offset_count];
			
			offset_count += 1;
			
		characterData[cur_pose]["Offset"] = [
			offset_array[cur_pose][0],
			offset_array[cur_pose][1]
		];
		
		characterData[cur_pose]["anim beat"] = int(animBeats[cur_pose]);
		characterData[cur_pose]["Anim Time"] = int(animTimes[cur_pose]);
		characterData[cur_pose]["special anim"] = specialAnims[cur_pose];
		
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
			"camera follow pos": %cam_follow_poses.button_pressed
		};
		
	%x_offset.value = offset_array[cur_pose][0];
	%y_offset.value = offset_array[cur_pose][1];
	%beat_time.value = animBeats[cur_pose];
	%anim_time.value = animTimes[cur_pose];
	%is_special.button_pressed = specialAnims[cur_pose];
	
func addCharToList():
	var charList = [];
	for i in getFolderShit("assets/data/characters/"):
		if i.ends_with(".json") && !i == "none":
			charList.append(i);
			
	return charList;
	
func getFolderShit(folder):
	var file = [];
	var coolFolder = DirAccess.open("res://%s"%[folder]);
	if coolFolder:
		coolFolder.list_dir_begin();
		var nameShit = coolFolder.get_next();
		while nameShit != "":
			file.append(nameShit);
			nameShit = coolFolder.get_next();
			
	return file;
	
func save_file() -> void:
	$FileDialog.popup_centered();
	
func _on_file_dialog_file_selected(json):
	var new_jsonFile = FileAccess.open(json, FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(characterJson, "\t"));
	new_jsonFile.close();
	print(characterJson)
	print('save: ', json);
	
func _on_x_scale_value_changed(value: float) -> void:
	holding_char = false;
	can_grab = false;
	update_scale_value(value, %y_scale.value);
	
func _on_y_scale_value_changed(value: float) -> void:
	holding_char = false;
	can_grab = false;
	update_scale_value(%x_scale.value, value);
	
func _on_flip_x_pressed() -> void:
	flip_char(%flipX.button_pressed, %flipY.button_pressed);
	
func _on_flip_y_pressed() -> void:
	flip_char(%flipX.button_pressed, %flipY.button_pressed);
	
func _on_camera_x_value_changed(value: float) -> void:
	holding_char = false;
	can_grab = false;
	update_cross(value, %camera_Y.value);
	
func _on_camera_y_value_changed(value: float) -> void:
	holding_char = false;
	can_grab = false;
	update_cross(%camera_X.value, value);
	
func _on_y_offset_value_changed(value: float) -> void:
	can_grab = false;
	if offset_array.is_empty():
		return;
		
	offset_array[cur_pose][1] = value;
	update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
	
func _on_x_offset_value_changed(value: float) -> void:
	can_grab = false;
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
	
func _on_is_special_toggled(toggled_on: bool) -> void:
	if specialAnims.is_empty():
		return;
		
	specialAnims[cur_pose] = toggled_on;

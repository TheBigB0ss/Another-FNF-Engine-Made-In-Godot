extends Node2D

#stage editor (BETA VERSION 1.0)

@onready var stage_camera = $Camera2D;
@onready var satge_button = $"CanvasLayer/TabContainer/stage stuff/stages";
@onready var stage = $stage;

@onready var element_anim = $"CanvasLayer/TabContainer/stage stuff/animations";

@onready var container = $CanvasLayer/TabContainer;

@onready var bf = $Boyfriend;
@onready var dad = $'Dad';
@onready var gf = $Gf;

var stages = null;
var cur_stage = null;

var stage_list = [];
var replaced = "";

var opponent_pos = [];
var bf_pos = [];
var gf_pos = [];

var anim_list = [];

func _ready() -> void:
	Discord.update_discord_info("stage editor", "Is in menus");
	MusicManager._play_music(GlobalOptions.updated_pause_music, false, true);
	element_anim.connect("item_selected",  change_anim);
	
	for i in addStageToList():
		if i.contains(".json"):
			replaced = i.replace(".json", "");
			
		stage_list.append(replaced);
		satge_button.add_item(i.replace(".json", ""));
		
	satge_button.connect("item_selected", change_bg);
	
	change_bg(0)
	
func change_anim(char):
	is_updating = true;
	print(anim_list[element_anim.selected]);
	if current_obj != null:
		if current_obj is AnimatedSprite2D:
			current_obj.play(anim_list[element_anim.selected]);
			
func change_bg(char):
	for i in stage.get_children():
		stage.remove_child(i);
		i.queue_free();
		
	var new_stage = load("res://source/stages/%s.tscn"%[stage_list[satge_button.selected]]).instantiate();
	cur_stage = new_stage;
	stage.add_child(new_stage);
	
	opponent_pos = get_stage_json(stage_list[satge_button.selected])["opponent"];
	bf_pos = get_stage_json(stage_list[satge_button.selected])["bf"];
	gf_pos = get_stage_json(stage_list[satge_button.selected])["gf"];
	
	bf.position = Vector2(bf_pos[0], bf_pos[1]);
	dad.position = Vector2(opponent_pos[0], opponent_pos[1]);
	gf.position = Vector2(gf_pos[0], gf_pos[1]);
	
	bf.z_index = get_stage_json(stage_list[satge_button.selected])["bf Z_Index"];
	gf.z_index = get_stage_json(stage_list[satge_button.selected])["gf Z_Index"];
	dad.z_index = get_stage_json(stage_list[satge_button.selected])["opponent Z_Index"];
	
	for j in element_anim.get_item_count():
		element_anim.remove_item(j);
		anim_list = [];
		
	%bf_x.value = bf_pos[0];
	%bf_y.value = bf_pos[1];
	%bf_zIndex.value = get_stage_json(stage_list[satge_button.selected])["bf Z_Index"];
	
	%opponent_x.value = opponent_pos[0];
	%opponent_y.value = opponent_pos[1];
	%opponent_zIndex.value = get_stage_json(stage_list[satge_button.selected])["opponent Z_Index"];
	
	%gf_x.value = gf_pos[0];
	%gf_y.value = gf_pos[1];
	%gf_zIndex.value = get_stage_json(stage_list[satge_button.selected])["gf Z_Index"];
	
	%stage_zoom.value = get_stage_json(stage_list[satge_button.selected])["stage zoom"];
	%stage_beat_zoom.value = get_stage_json(stage_list[satge_button.selected])["stage beat zoom"];
	
var updated_camX = 0;
var updated_camY = 0;
func _input(ev) -> void:
	if ev is InputEventKey:
		if ev.pressed:
			if ev.keycode in [KEY_UP]:
				updated_camY -= 25;
				update_canera_offset(updated_camX, updated_camY);
				
			if ev.keycode in [KEY_DOWN]:
				updated_camY += 25;
				update_canera_offset(updated_camX, updated_camY);
				
			if ev.keycode in [KEY_LEFT]:
				updated_camX -= 25;
				update_canera_offset(updated_camX, updated_camY);
				
			if ev.keycode in [KEY_RIGHT]:
				updated_camX += 25;
				update_canera_offset(updated_camX, updated_camY);
				
		if ev.pressed && !ev.echo:
			if ev.keycode in [KEY_ESCAPE] && !ev.echo:
				MusicManager._play_music("freakyMenu", true, true);
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
func update_canera_offset(x, y):
	stage_camera.offset = Vector2(x, y);
	
var current_obj = null;
var is_updating = false;
func _process(delta: float) -> void:
	bf.position = Vector2(%bf_x.value, %bf_y.value);
	dad.position = Vector2(%opponent_x.value, %opponent_y.value);
	gf.position = Vector2(%gf_x.value, %gf_y.value);
	
	bf.z_index = %bf_zIndex.value;
	gf.z_index = %gf_zIndex.value;
	dad.z_index = %opponent_zIndex.value;
	
	if !$FileDialog.visible:
		if Input.is_action_just_released("mouse_wheel_down") or Input.is_action_pressed("input_S"):
			if stage_camera.zoom.x < 0.15:
				return;
				
			stage_camera.zoom.x -= 0.2/6;
			stage_camera.zoom.y -= 0.2/6;
			
		if Input.is_action_just_released("mouse_wheel_up") or Input.is_action_pressed("input_W"):
			stage_camera.zoom.x += 0.2/8;
			stage_camera.zoom.y += 0.2/8;
			
	if get_viewport().gui_get_hovered_control() is ColorPicker && get_viewport().gui_get_hovered_control() is TabBar or get_viewport().gui_get_hovered_control() is SpinBox or get_viewport().gui_get_hovered_control() is ColorPickerButton or get_viewport().gui_get_hovered_control() is CheckBox or get_viewport().gui_get_hovered_control() is LineEdit or get_viewport().gui_get_hovered_control() is Button or get_viewport().gui_get_hovered_control() is OptionButton:
		is_updating = true;
	else:
		is_updating = false;
		
	#print(is_updating)
	
	if !color_changed && !$FileDialog.visible:
		if !mouse_inside_container() && !is_updating:
			if Input.is_action_just_pressed("mouse_click"):
				var node_clicked = mouse_detected(cur_stage);
				if node_clicked:
					current_obj = node_clicked;
					
					if current_obj is AnimatedSprite2D:
						element_anim.disabled = false;
						
						for j in element_anim.get_item_count():
							element_anim.remove_item(j);
							anim_list = [];
							
						for j in current_obj.sprite_frames.get_animation_names():
							anim_list.append(j);
							print(anim_list);
							
						for j in anim_list.size():
							element_anim.add_item(anim_list[j]);
							
					else:
						element_anim.disabled = true;
						for i in element_anim.get_item_count():
							element_anim.remove_item(i);
							anim_list = [];
							
					%"obj X".value = current_obj.position.x;
					%"obj Y".value = current_obj.position.y;
					
					%"obj width".value = current_obj.scale.x;
					%"obj height".value = current_obj.scale.y;
					
					%obj_rotation.value = current_obj.rotation;
					
					%obj_zIndex.value = current_obj.z_index;
					
					if is_updating:
						%obj_color.color = current_obj.modulate;
						
					print(current_obj)
					
	#if can_grab:
	#	update_canera_offset(get_global_mouse_position().x/2, get_global_mouse_position().y/2)
		
func mouse_inside_container():
	var mouse = get_global_mouse_position();
	if mouse.x > container.global_position.x+720 - container.size.x-90 && mouse.x < container.global_position.x+280 + container.size.x+420 && mouse.y > container.global_position.y - container.size.y-100 && mouse.y < container.global_position.y + container.size.y:
		return true;
		
	return false;
	
func addStageToList():
	var charList = [];
	var char = getFolderShit("assets/stages/data/");
	for i in char:
		if i.ends_with(".json"):
			charList.append(i);
			
	return charList;
	
func get_stage_json(stage):
	var info = {}
	var replaced = stage;
	
	var jsonFile = FileAccess.open("res://assets/stages/data/%s.json"%[replaced],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	info = jsonData.get_data()
	jsonFile.close();
	
	set_stage_null_var(info, "gf Z_Index", 0);
	set_stage_null_var(info, "opponent Z_Index", 0);
	set_stage_null_var(info, "bf Z_Index", 0);
	set_stage_null_var(info, "stage zoom", 0.8);
	set_stage_null_var(info, "stage beat zoom", 0.83);
	
	return info;
	
func set_stage_null_var(dict, cool_var, new_value):
	if !dict.has(cool_var):
		dict[cool_var] = new_value;
		
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
	
func mouse_detected(node):
	var mouse = get_global_mouse_position();
	for i in range(node.get_child_count() - 1, -1, -1):
		var spr = node.get_child(i);
		
		if is_updating:
			return;
			
		var result = mouse_detected(spr);
		if result:
			return result
			
		if spr is AnimatedSprite2D:
			var size = spr.sprite_frames.get_frame_texture(spr.animation, spr.frame).get_size() * spr.scale;
			if mouse.x > spr.global_position.x - size.x / 2 && mouse.x < spr.global_position.x + size.x / 2 && mouse.y > spr.global_position.y - size.y / 2 && mouse.y < spr.global_position.y + size.y / 2:
				return spr;
				
		elif spr is Sprite2D:
			var size = spr.get_texture().get_size() * spr.scale
			if mouse.x > spr.global_position.x - size.x / 2 && mouse.x < spr.global_position.x + size.x / 2 && mouse.y > spr.global_position.y - size.y / 2 && mouse.y < spr.global_position.y + size.y / 2:
				return spr;
				
func _on_save_json_pressed():
	$FileDialog.popup_centered();
	
func _on_save_sprite_pressed() -> void:
	if !%animated_sprite.button_pressed:
		var new_sprite = Sprite2D.new();
		new_sprite.texture = load("res://assets/%s.png"%[%sprite_name.text]);
		new_sprite.z_index = %sprite_layer.value;
		cur_stage.add_child(new_sprite);
	else:
		var new_sprite = AnimatedSprite2D.new();
		new_sprite.sprite_frames = load("res://assets/%s.res"%[%sprite_name.text]);
		new_sprite.z_index = %sprite_layer.value;
		element_anim.disabled = false;
		cur_stage.add_child(new_sprite);
		
		for i in new_sprite.sprite_frames.get_animation_names():
			anim_list.append(i);
			
func save_json(path):
	var new_jsonFile = FileAccess.open(path, FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify({
		"opponent": [%opponent_x.value, %opponent_y.value],
		"gf": [%gf_x.value, %gf_y.value],
		"bf": [%bf_x.value, %bf_y.value],
		"gf Z_Index": %gf_zIndex.value,
		"bf Z_Index": %bf_zIndex.value,
		"opponent Z_Index": %opponent_zIndex.value,
		"stage zoom": %stage_zoom.value,
		"stage beat zoom": %stage_beat_zoom.value
	}, "\t"));
	new_jsonFile.close();
	print('save: ', path);
	
func _on_obj_x_value_changed(value: float) -> void:
	current_obj.position.x = value;
	is_updating = true;
	
func _on_obj_y_value_changed(value: float) -> void:
	current_obj.position.y = value;
	is_updating = true;
	
func _on_obj_width_value_changed(value: float) -> void:
	current_obj.scale.x = value;
	is_updating = true;
	
func _on_obj_height_value_changed(value: float) -> void:
	current_obj.scale.y = value;
	is_updating = true;
	
var color_changed = false;
func _on_obj_color_color_changed(color: Color) -> void:
	current_obj.modulate = color;
	color_changed = true;
	
func _on_obj_rotation_value_changed(value: float) -> void:
	current_obj.rotation = value;
	is_updating = true;
	
func _on_obj_z_index_value_changed(value: float) -> void:
	current_obj.z_index = value;
	is_updating = true;
	
func _on_create_stage_pressed() -> void:
	var new_jsonFile = FileAccess.open("res://assets/stages/data/%s.json"%[%stage_name.text], FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify({
		"opponent": [0, 0],
		"gf": [0, 0],
		"bf": [0, 0],
		"gf Z_Index": 0,
		"bf Z_Index": 0,
		"opponent Z_Index": 0
	}, "\t"));
	
	new_jsonFile.close();
	var node = Node2D.new();
	node.name = %stage_name.text;
	add_child(node)
	
	var packed_scene = PackedScene.new();
	packed_scene.pack(node);
	
	stage_list.append(%stage_name.text);
	satge_button.add_item(%stage_name.text)
	
	ResourceSaver.save(packed_scene, "res://source/stages/%s"%[%stage_name.text] + ".tscn", ResourceSaver.FLAG_COMPRESS);
	
func _on_load_stage_pressed() -> void:
	for i in satge_button.get_item_count():
		if satge_button.get_item_text(i) == %stage_name.text:
			satge_button.select(i);
			change_bg(i)
			
func _on_save_stage_pressed() -> void:
	var packed_scene = PackedScene.new();
	packed_scene.pack(cur_stage);
	
	ResourceSaver.save(packed_scene, "res://source/stages/%s.tscn"%[stage_list[satge_button.selected]], ResourceSaver.FLAG_COMPRESS);
	
func _on_obj_color_picker_created() -> void:
	is_updating = true;
	
func _on_obj_color_popup_closed() -> void:
	color_changed = false;
	
func _on_animations_item_focused(index: int) -> void:
	is_updating = true;

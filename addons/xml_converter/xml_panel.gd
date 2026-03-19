@tool
extends Control

var new_anims = []:
	set(val):
		new_anims = val.split(",") if val.contains(",") else [val];
		if val == "":
			new_anims = [];
	get:
		return new_anims;
		
func _ready() -> void:
	new_anims = %LineEdit3.text;
	
func _on_check_box_2_toggled(toggled_on: bool) -> void:
	%SpinBox2.editable = toggled_on;
	%LineEdit3.editable = !toggled_on;
	
func _on_button_pressed() -> void:
	var click = EditorInterface.get_selection();
	
	var lineText1 = %LineEdit1.text;
	var lineText2 = %LineEdit2.text;
	var loop = %CheckBox.button_pressed;
	var speed = %SpinBox.value;
	
	if !%CheckBox2.button_pressed:
		if %CheckBox3.button_pressed:
			create_res_by_txt(lineText1, lineText2, loop, speed);
		else:
			create_res_file(lineText1, lineText2, loop, speed);
	else:
		if %CheckBox3.button_pressed:
			create_tscn_by_txt(lineText1, lineText2, loop, speed);
		else:
			create_tscn_file(lineText1, lineText2, loop, speed);
			
func create_tscn_file(image, anim, haveLoop, fps):
	var node = Node2D.new();
	var animPlayer = AnimationPlayer.new();
	var sprite = Sprite2D.new();
	
	node.name = anim;
	node.set_script(preload("res://source/characters/characters_scripts/New_Character.gd"));
	sprite.name = "Character_Sprite";
	animPlayer.name = "Character_Animation";
	
	sprite.texture = load("res://assets/%s.png"%[image]);
	sprite.region_enabled = true;
	sprite.centered = true;
	
	node.add_child(sprite);
	node.add_child(animPlayer);
	sprite.set_owner(node);
	animPlayer.set_owner(node);
	
	add_anim(animPlayer, image,fps, haveLoop, [node, sprite]);
	
	var packed_scene = PackedScene.new();
	packed_scene.pack(node);
	
	var lib = AnimationLibrary.new();
	for i in animPlayer.get_animation_list():
		var libAnim = animPlayer.get_animation(i);
		lib.add_animation(i, libAnim);
		
	ResourceSaver.save(lib, "res://assets/%s"%[anim] + ".tres", ResourceSaver.FLAG_COMPRESS);
	ResourceSaver.save(packed_scene, "res://assets/%s"%[anim] + ".tscn", ResourceSaver.FLAG_COMPRESS);
	
func create_res_file(image, anim, haveLoop, fps):
	var animationSTUFF = SpriteFrames.new();
	animationSTUFF.remove_animation("default");
	
	var node = Node2D.new();
	node.name = anim;
	node.set_script(preload("res://source/characters/characters_scripts/Character.gd"));
	
	var animated_spr = AnimatedSprite2D.new();
	animated_spr.name = "character";
	node.add_child(animated_spr);
	
	animated_spr.set_owner(node);
	
	add_anim(animationSTUFF, image, fps, haveLoop)
	
	if !new_anims.is_empty():
		for i in new_anims:
			add_anim(animationSTUFF, i, fps, haveLoop);
			
	animated_spr.sprite_frames = animationSTUFF;
	
	var packed_scene = PackedScene.new();
	packed_scene.pack(node);
	
	ResourceSaver.save(packed_scene, "res://assets/%s.tscn"%[anim], ResourceSaver.FLAG_COMPRESS);
	ResourceSaver.save(animationSTUFF, "res://assets/%s.res" % anim, ResourceSaver.FLAG_COMPRESS)
	
func create_res_by_txt(image, anim, haveLoop, fps):
	var txtData = [];
	var fileParser = FileAccess.open("res://assets/%s.txt"%[image], FileAccess.READ);
	txtData = fileParser.get_as_text().split("\n");
	
	var animationSTUFF = SpriteFrames.new();
	animationSTUFF.remove_animation("default");
	
	var node = Node2D.new();
	var animated_spr = AnimatedSprite2D.new();
	
	node.name = anim;
	node.set_script(preload("res://source/characters/characters_scripts/Character.gd"));
	animated_spr.name = "character";
	
	node.add_child(animated_spr);
	animated_spr.set_owner(node);
	
	for i in txtData:
		if i != "":
			var frameTexture = AtlasTexture.new();
			frameTexture.atlas = load("res://assets/%s.png"%[image]);
			
			var xml_data = i.split("=");
			var anims = xml_data[0].split("_");
			var animData = xml_data[1].split(" ");
			
			for j in animData.size()-1:
				if animData[j] == " " or animData[j] == "":
					animData.remove_at(j);
					
			var anim_name = anims[0];
			var anim_data_list = animData;
			
			frameTexture.region = Rect2(
				Vector2(anim_data_list[0].to_int(), anim_data_list[1].to_int()),
				Vector2(anim_data_list[2].to_int(), anim_data_list[3].to_int())
			);
			
			if !animationSTUFF.has_animation(anim_name):
				animationSTUFF.add_animation(anim_name);
				animationSTUFF.set_animation_loop(anim_name, haveLoop);
				animationSTUFF.set_animation_speed(anim_name, fps);
				
			animationSTUFF.add_frame(anim_name, frameTexture);
			
	animated_spr.sprite_frames = animationSTUFF;
	
	var packed_scene = PackedScene.new();
	packed_scene.pack(node);
	
	ResourceSaver.save(packed_scene, "res://assets/%s"%[anim] + ".tscn", ResourceSaver.FLAG_COMPRESS);
	ResourceSaver.save(animationSTUFF, "res://assets/%s"%[anim] + ".res", ResourceSaver.FLAG_COMPRESS);
	
func create_tscn_by_txt(image, anim, haveLoop, fps):
	var node = Node2D.new();
	var animPlayer = AnimationPlayer.new();
	var sprite = Sprite2D.new();
	
	node.name = anim;
	node.set_script(preload("res://source/characters/characters_scripts/New_Character.gd"));
	sprite.name = "Character_Sprite";
	animPlayer.name = "Character_Animation";
	
	sprite.texture = load("res://assets/%s.png"%[image]);
	sprite.region_enabled = true;
	sprite.centered = true;
	
	node.add_child(sprite);
	node.add_child(animPlayer);
	sprite.set_owner(node);
	animPlayer.set_owner(node);
	
	var txtData = [];
	var fileParser = FileAccess.open("res://assets/%s.txt"%[image], FileAccess.READ);
	txtData = fileParser.get_as_text().split("\n");
	
	var anim_name = [];
	var anim_region_data = [];
	var anim_data_list = [];
	var anim_count = [];
	var cool_data = {};
	
	for i in txtData:
		if i != "":
			var frameTexture = AtlasTexture.new();
			frameTexture.atlas = load("res://assets/%s.png"%[image]);
			
			var xml_data = i.split("=");
			var anims = xml_data[0].split("_");
			var animData = xml_data[1].split(" ");
			
			for j in animData.size()-1:
				if animData[j] == " " or animData[j] == "":
					animData.remove_at(j);
					
			anim_region_data = animData;
			
			if !anim_name.has(anims[0]):
				anim_name.append(anims[0]);
				
			anim_count.append(xml_data[0])
			
		cool_data = {
			anim_name[anim_name.size()-1]: [
				anim_region_data[0], 
				anim_region_data[1], 
				anim_region_data[2], 
				anim_region_data[3]
			]
		};
		
		anim_data_list.append(cool_data);
		
	var anim_lib = AnimationLibrary.new();
	for i in anim_name.size():
		var new_anim = Animation.new();
		var index = new_anim.add_track(Animation.TYPE_VALUE);
		var cool_name = anim_name[i];
		
		new_anim.track_set_interpolation_type(index, Animation.INTERPOLATION_NEAREST);
		new_anim.track_set_path(index, "%s:region_rect"%[node.get_path_to(sprite)]);
		
		new_anim.loop_mode = haveLoop;
		
		var cur_frame = 0;
		for j in range(anim_count.size()):
			for key in anim_data_list[j].keys():
				if key == cool_name:
					var region_margin = Rect2(
						Vector2(anim_data_list[j][key][0].to_int(), anim_data_list[j][key][1].to_int()),
						Vector2(anim_data_list[j][key][2].to_int(), anim_data_list[j][key][3].to_int())
					);
					
					new_anim.track_insert_key(index, cur_frame * 0.03, region_margin);
					new_anim.length = cur_frame*0.03
					cur_frame += 1;
					
		cool_name = cool_name.strip_edges().trim_suffix("/");
		anim_lib.add_animation(cool_name, new_anim);
		
	animPlayer.add_animation_library("", anim_lib);
	
	var packed_scene = PackedScene.new();
	packed_scene.pack(node);
	
	ResourceSaver.save(packed_scene, "res://assets/%s"%[anim] + ".tscn", ResourceSaver.FLAG_COMPRESS);
	
func add_anim(animPlayer, image, fps, loop, args = []):
	var fileParser = XMLParser.new();
	fileParser.open("res://assets/%s.xml"%[image]);
	
	if fileParser.read() != OK:
		print("error in %s.xml"%[image]);
		return;
		
	if animPlayer is AnimationPlayer:
		var new_animation = [];
		var data_list = [];
		var new_anim_data = [];
		
		while fileParser.read() == OK:
			var xmlList = {
				"animation": [],
				"x": fileParser.get_named_attribute_value_safe("x").to_int(),
				"y": fileParser.get_named_attribute_value_safe("y").to_int(),
				"width": fileParser.get_named_attribute_value_safe("width").to_int(),
				"height": fileParser.get_named_attribute_value_safe("height").to_int(),
				"frameX": fileParser.get_named_attribute_value_safe("frameX").to_int(),
				"frameY": fileParser.get_named_attribute_value_safe("frameY").to_int(),
				"frameWidth": fileParser.get_named_attribute_value_safe("frameWidth").to_int(),
				"frameHeight": fileParser.get_named_attribute_value_safe("frameHeight").to_int(),
				"rotated": fileParser.get_named_attribute_value_safe("rotated") == "true"
			};
			
			var anim_name = fileParser.get_named_attribute_value_safe("name");
			if fileParser.get_named_attribute_value_safe("name") != "":
				var animArray = [];
				for i in fileParser.get_named_attribute_value_safe("name"):
					animArray.append(i);
					
				xmlList["animation"].append(''.join(animArray).substr(0, animArray.size() - 4));
				
				for i in xmlList["animation"]:
					if !new_animation.has(i):
						new_animation.append(i);
						
				var new_anim = anim_name.substr(0, len(anim_name) - 4);
				
				new_anim_data.append_array(xmlList["animation"])
				
				data_list.append({
					new_anim: [
						xmlList["x"],
						xmlList["y"], 
						xmlList["width"], 
						xmlList["height"],
						xmlList["frameX"], 
						xmlList["frameY"], 
						xmlList["frameWidth"],
						xmlList["frameHeight"],
						xmlList["rotated"]
					]
				});
				
		var anim_lib = AnimationLibrary.new();
		var cur_animName = "";
		for i in new_animation.size():
			var new_anim = Animation.new();
			
			var index = new_anim.add_track(Animation.TYPE_VALUE);
			var index_offset = new_anim.add_track(Animation.TYPE_VALUE);
			var rotation_track = new_anim.add_track(Animation.TYPE_VALUE);
			
			cur_animName = new_animation[i];
			
			new_anim.track_set_interpolation_type(index, Animation.INTERPOLATION_NEAREST);
			new_anim.track_set_interpolation_type(index_offset, Animation.INTERPOLATION_NEAREST);
			new_anim.track_set_interpolation_type(rotation_track, Animation.INTERPOLATION_NEAREST);
			
			new_anim.track_set_path(index, "%s:region_rect"%[args[0].get_path_to(args[1])]);
			new_anim.track_set_path(rotation_track, "%s:rotation_degrees"%[args[0].get_path_to(args[1])]);
			new_anim.track_set_path(index_offset, "%s:offset"%[args[0].get_path_to(args[1])]);
			
			new_anim.loop_mode = loop;
			
			var cur_frame = 0;
			var rotated_frame = false;
			for j in range(new_anim_data.size()):
				if data_list[j].has(cur_animName):
					var rotated = data_list[j][cur_animName].size() > 8 && data_list[j][cur_animName][8];
					
					if rotated:
						rotated_frame = true;
						
				for key in data_list[j].keys():
					if key != cur_animName:
						continue;
						
					var region_margin = Rect2(
						Vector2(data_list[j][key][0], data_list[j][key][1]),
						Vector2(data_list[j][key][2], data_list[j][key][3])
					);
					
					var offset_x = 0.0;
					var offset_y = 0.0;
					
					if rotated_frame:
						offset_x = int(data_list[j][key][4]);
						offset_y = int(data_list[j][key][5]);
					else:
						offset_x = int(data_list[j][key][4]) + (int(data_list[j][key][6]) - int(data_list[j][key][2])) / 2.0;
						offset_y = int(data_list[j][key][5]) + (int(data_list[j][key][7]) - int(data_list[j][key][3])) / 2.0;
						
					var offset_margin = Vector2(offset_y, -offset_x) if rotated_frame else -Vector2(offset_x, offset_y);
					
					new_anim.track_insert_key(index, cur_frame * 0.03, region_margin);
					new_anim.track_insert_key(index_offset, cur_frame * 0.03, offset_margin);
					new_anim.track_insert_key(rotation_track, cur_frame * 0.03, 90*%SpinBox2.value if data_list[j][key].size() > 8 && data_list[j][key][8] else 0.0);
					new_anim.length = cur_frame*0.03;
					
					cur_frame += 1;
					
			cur_animName = cur_animName.strip_edges().trim_suffix("/");
			anim_lib.add_animation(cur_animName, new_anim);
			
		animPlayer.add_animation_library("", anim_lib);
		
	if animPlayer is SpriteFrames:
		if animPlayer.has_animation("default"):
			animPlayer.remove_animation("default");
			
		while fileParser.read() == OK:
			var xmlList = {
				"animation": [],
				"x": fileParser.get_named_attribute_value_safe("x").to_int(),
				"y": fileParser.get_named_attribute_value_safe("y").to_int(),
				"width": fileParser.get_named_attribute_value_safe("width").to_int(),
				"height": fileParser.get_named_attribute_value_safe("height").to_int(),
				"frameX": fileParser.get_named_attribute_value_safe("frameX").to_int(),
				"frameY": fileParser.get_named_attribute_value_safe("frameY").to_int(),
				"frameWidth": fileParser.get_named_attribute_value_safe("frameWidth").to_int(),
				"frameHeight": fileParser.get_named_attribute_value_safe("frameHeight").to_int(),
				"rotated": fileParser.get_named_attribute_value_safe("rotated") == "true"
			};
			var frameTexture = AtlasTexture.new();
			frameTexture.atlas = load("res://assets/%s.png"%[image])
			
			if fileParser.get_named_attribute_value_safe("name") != '':
				var animArray = [];
				for i in fileParser.get_named_attribute_value_safe("name"):
					animArray.append(i);
					
				xmlList["animation"].append(''.join(animArray).substr(0, animArray.size() - 4));
				
				frameTexture.region = Rect2(
					Vector2(xmlList["x"], xmlList["y"]),
					Vector2(xmlList["width"], xmlList["height"])
				);
				
				frameTexture.margin = Rect2(
					Vector2(-int(xmlList["frameX"]),-int(xmlList["frameY"])),
					Vector2(int(xmlList["frameWidth"]) - frameTexture.region.size.x, int(xmlList["frameHeight"]) - frameTexture.region.size.y)
				);
				
				if frameTexture.margin.size.x < abs(frameTexture.margin.position.x):
					frameTexture.margin.size.x = abs(frameTexture.margin.position.x);
					
				if frameTexture.margin.size.y < abs(frameTexture.margin.position.y):
					frameTexture.margin.size.y = abs(frameTexture.margin.position.y);
					
				var curAnimation = '';
				for j in xmlList["animation"]:
					if j != '':
						curAnimation = j;
						
				if !animPlayer.has_animation(curAnimation):
					animPlayer.add_animation(curAnimation);
					animPlayer.set_animation_loop(curAnimation, loop);
					animPlayer.set_animation_speed(curAnimation, fps);
					
				animPlayer.add_frame(curAnimation, frameTexture);

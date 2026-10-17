@tool
class_name SparrowSprite extends Node2D

var atlasTexture:AtlasTexture = AtlasTexture.new();

@export_group("animation path", "")
@export var texture:Texture2D:
	set(value):
		texture = value;
		atlasTexture.atlas = texture;
		
		var json_path = value.resource_path.get_basename() + ".json";
		var xml_path = value.resource_path.get_basename() + ".xml";
		
		if FileAccess.file_exists(json_path):
			data_path = json_path;
		elif FileAccess.file_exists(xml_path):
			data_path = xml_path;
			
		queue_redraw();
		
@export_file_path var data_path = "":
	set(value):
		data_path = value;
		reload();
		
@export_group("playback")
@export var frame = 0;
@export var fps = 16.0:
	set(value):
		fps = maxf(absf(value), 0.001);
		
		if animations.is_empty():
			return;
			
		var anim_name = animations[animation];
		set_anim_speed(anim_name, value);
		
@export var loop = true:
	set(value):
		loop = value;
		
		if animations.is_empty():
			return;
			
		var anim_name = animations[animation];
		set_anim_loop(anim_name, value);
		
@export var playing = true:
	set(val):
		if playing != val:
			playing = val;
			frame = 0.0;
			timer = 0.0;
			
@export_group("transform")
@export var sprite_centered = true;

@export_enum("DEFAULT:0", "ASEPRITE:1")
var center_mode = 0:
	set(value):
		center_mode = value;
		queue_redraw();
		
@export var offset:Vector2 = Vector2.ZERO;
@export var flip_h = false;
@export var flip_v = false;

@export_group("set animation")
var animation = 0:
	set(value):
		animation = value;
		queue_redraw();
		
		if animations.is_empty():
			return;
			
		current_animation = animations[value];
		
		loop = get_anim_loop(current_animation);
		fps = get_anim_speed(current_animation);
		
var animations = [];
var infoList = {};

@export var anims_data = {};

var current_animation = "";

signal animation_finished;
signal animation_change(anim);

func reload():
	animations.clear();
	infoList.clear();
	
	if data_path.get_extension().to_lower() == "json":
		convert_json();
	else:
		convert_xml();
		
	for i in animations:
		if !anims_data.has(i):
			anims_data[i] = {
				"loop": loop,
				"fps": fps
			};
			
	notify_property_list_changed();
	queue_redraw();
	
func convert_xml():
	var fileParser = XMLParser.new();
	fileParser.open(data_path);
	
	if fileParser.read() != OK:
		print("error in ", data_path);
		return;
		
	while fileParser.read() == OK:
		var width = fileParser.get_named_attribute_value_safe("width").to_int();
		var height = fileParser.get_named_attribute_value_safe("height").to_int();
		
		var frame_width = fileParser.get_named_attribute_value_safe("frameWidth");
		var frame_height = fileParser.get_named_attribute_value_safe("frameHeight");
		var list = {
			"x": fileParser.get_named_attribute_value_safe("x").to_int(),
			"y": fileParser.get_named_attribute_value_safe("y").to_int(),
			"width": width,
			"height": height,
			"frameX": fileParser.get_named_attribute_value_safe("frameX").to_int(),
			"frameY": fileParser.get_named_attribute_value_safe("frameY").to_int(),
			"frameWidth": width if frame_width == "" else frame_width.to_int(),
			"frameHeight": height if frame_height == "" else frame_height.to_int(),
			"rotated": fileParser.get_named_attribute_value_safe("rotated") == "true"
		};
		
		if fileParser.get_node_type() != XMLParser.NODE_ELEMENT:
			continue;
			
		if fileParser.get_node_name() != "SubTexture":
			continue;
			
		if fileParser.get_named_attribute_value_safe("name") != "":
			var animArray = [];
			for i in fileParser.get_named_attribute_value_safe("name"):
				animArray.append(i);
				
			var anim_name = ''.join(animArray).substr(0, animArray.size() - 4);
			if !infoList.has(anim_name):
				infoList[anim_name] = [];
				
			infoList[anim_name].append(list);
			
			if !animations.has(anim_name):
				animations.append(anim_name);
				
func convert_json():
	var file = FileAccess.open(data_path, FileAccess.READ);
	
	if file == null:
		print("error in ", data_path);
		return;
		
	var data = JSON.parse_string(file.get_as_text());
	
	if typeof(data) == TYPE_DICTIONARY:
		var frame_data = data.get("animations", {});
		var meta = data.get("meta", {});
		var frame_tags = meta.get("frameTags", []);
		
		var frame_names = frame_data.keys();
		
		for i in frame_tags:
			var anim_name = str(i.get("name", ""));
			var from_frame = int(i.get("from", 0));
			var to_frame = int(i.get("to", 0));
			
			if anim_name.is_empty():
				continue;
				
			if !infoList.has(anim_name):
				infoList[anim_name] = [];
				
			for j in range(from_frame, to_frame + 1):
				if j >= frame_names.size():
					continue;
					
				var sprite_frame = frame_data[frame_names[j]].get("frame", {});
				var sprite_source = frame_data[frame_names[j]].get("spriteSourceSize", {});
				var source_size = frame_data[frame_names[j]].get("sourceSize", {});
				
				var list = {
					"x": int(sprite_frame.get("x", 0)),
					"y": int(sprite_frame.get("y", 0)),
					"width": int(sprite_frame.get("w", 0)),
					"height": int(sprite_frame.get("h", 0)),
					"frameX": int(sprite_source.get("x", 0)),
					"frameY": int(sprite_source.get("y", 0)),
					"frameWidth": int(source_size.get("w", sprite_frame.get("w", 0))),
					"frameHeight": int(source_size.get("h", sprite_frame.get("h", 0))),
					"rotated": bool(frame_data[frame_names[j]].get("rotated", false)),
					"duration": float(frame_data[frame_names[j]].get("duration", 100))
				};
				
				infoList[anim_name].append(list);
				
			animations.append(anim_name);
			
var timer = 0.0;

func _process(delta: float) -> void:
	scale.x = abs(scale.x) * (-1 if flip_h else 1);
	scale.y = abs(scale.y) * (-1 if flip_v else 1);
	
	if animations.is_empty():
		return;
		
	if Engine.is_editor_hint():
		var new_fps = float(anims_data[animations[animation]].get("fps", fps));
		var new_loop = (anims_data[animations[animation]].get("loop", loop));
		
		if !is_equal_approx(fps, new_fps):
			fps = new_fps;
			queue_redraw();
			
		if loop != new_loop:
			loop = new_loop;
			queue_redraw();
			
	#print(loop, ' ', anims_data[animations[animation]].get("loop", loop))
	if playing:
		timer += delta*1000;
		
		var frame_duration = get_frame_duration();
		
		while timer >= frame_duration:
			timer -= frame_duration;
			frame += 1;
			
			if frame >= get_anim_length(animations[animation]):
				animation_finished.emit();
				if get_anim_loop(animations[animation]):
					frame = 0;
				else:
					frame = get_anim_length(animations[animation]) - 1;
					break;
					
		queue_redraw();
		
func get_frame_info(anim):
	var anim_animations = infoList.get(anim, []);
	
	if anim_animations.is_empty():
		return {};
		
	frame = clamp(frame, 0, anim_animations.size() - 1);
	return anim_animations[frame];
	
func get_anim_info(anim):
	return infoList.get(anim, []);
	
func get_anim_length(anim):
	return infoList.get(anim, []).size();
	
func get_anim_loop(anim):
	return anims_data.get(anim, {}).get("loop", loop);
	
func get_anim_speed(anim):
	return float(anims_data.get(anim, {}).get("fps", fps));
	
func set_anim_loop(anim_name, value):
	if anim_name.is_empty():
		return;
		
	if !anims_data.has(anim_name):
		anims_data[anim_name] = {
			"loop": value,
			"fps": fps
		};
		
	anims_data[anim_name]["loop"] = value;
	
func set_anim_speed(anim_name, value):
	if anim_name.is_empty():
		return;
		
	value = maxf(absf(value), 0.001);
	
	if !anims_data.has(anim_name):
		anims_data[anim_name] = {
			"loop": loop,
			"fps": value
		};
		
	anims_data[anim_name]["fps"] = value;
	
func get_frame_duration():
	var speed = get_anim_speed(current_animation);
	var duration = float(get_frame_info(animations[animation]).get("duration", 0.0));
	
	if duration <= 0.0:
		return 1000.0 / maxf(speed, 0.001);
		
	return duration * (10.0 / maxf(speed, 0.001));
	
func _draw() -> void:
	if animations.is_empty():
		return;
		
	var currentFrame = get_frame_info(animations[animation]);
	
	var rect = Rect2(
		Vector2(currentFrame["x"], currentFrame["y"]),
		Vector2(currentFrame["width"], currentFrame["height"])
	);
	
	var frame_offset = Vector2(
		-int(currentFrame["frameX"]),
		-int(currentFrame["frameY"])
	);
	if currentFrame["rotated"]:
		frame_offset = Vector2(
			-currentFrame["frameY"],
			-int(currentFrame["frameX"])
		);
		
	var margin = Rect2(
		frame_offset,
		Vector2(int(currentFrame["frameWidth"]) - rect.size.x, int(currentFrame["frameHeight"]) - rect.size.y) if !currentFrame["rotated"] else Vector2(currentFrame["frameHeight"] - rect.size.x,currentFrame["frameWidth"] - rect.size.y)
	);
	
	atlasTexture.region = rect;
	atlasTexture.margin = margin;
	
	if atlasTexture.margin.size.x < abs(atlasTexture.margin.position.x):
		atlasTexture.margin.size.x = abs(atlasTexture.margin.position.x);
		
	if atlasTexture.margin.size.y < abs(atlasTexture.margin.position.y):
		atlasTexture.margin.size.y = abs(atlasTexture.margin.position.y);
		
	var draw_pos:Vector2 = offset;
	if sprite_centered:
		var source_size = Vector2(
			currentFrame["frameWidth"],
			currentFrame["frameHeight"]
		);
		
		if center_mode == 0:
			draw_pos -= source_size / 2.0;
		else:
			draw_pos -= Vector2(
				currentFrame["width"],
				currentFrame["height"]
			) / 2.0;
			
			draw_pos += Vector2(
				currentFrame["frameX"],
				currentFrame["frameY"]
			);
			
	if currentFrame["rotated"]:
		draw_set_transform(draw_pos + Vector2(0, currentFrame["frameHeight"] - currentFrame["frameY"]), -PI / 2.0, Vector2.ONE);
		draw_texture(atlasTexture, Vector2.ZERO);
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE);
	else:
		draw_texture(atlasTexture, draw_pos);
		
func play(anim):
	if !infoList.has(anim):
		return;
		
	animation_change.emit(anim);
	
	current_animation = anim;
	animation = animations.find(anim);
	
	loop = get_anim_loop(current_animation);
	fps = get_anim_speed(current_animation);
	
	playing = true;
	timer = 0;
	frame = 0;
	
	queue_redraw();
	
func _get_property_list():
	var properties: Array[Dictionary] = [];
	
	properties.append({
		"name": "animation",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(infoList.keys()),
		"usage": PROPERTY_USAGE_DEFAULT
	});
	
	return properties;
	
func get_rect():
	if animations.is_empty():
		return Rect2();
		
	var currentFrame = get_frame_info(animations[animation]);
	var size = Vector2(
		currentFrame["frameWidth"],
		currentFrame["frameHeight"]
	) * abs(scale);
	
	var pos = global_position;
	
	if sprite_centered:
		pos -= size / 2.0;
		
	return Rect2(pos, size);
	

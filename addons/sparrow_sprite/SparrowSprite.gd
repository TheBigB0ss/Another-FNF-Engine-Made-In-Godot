@tool
class_name SparrowSprite extends Node2D

var atlasTexture:AtlasTexture = AtlasTexture.new();

@export var texture:Texture2D:
	set(value):
		texture = value;
		atlasTexture.atlas = texture;
		xmlPath = str(texture.resource_path.substr(0, len(texture.resource_path)-3), "xml");
		queue_redraw();
		
@export_file_path("*.xml") var xmlPath = "":
	set(value):
		xmlPath = value;
		reload();
		
@export var frame = 0;
@export var playing = true:
	set(val):
		if playing != val:
			playing = val;
			timer = 0.0;
			
@export var fps = 16;
@export var loop = true;

@export var sprite_centered:bool = true;
@export var offset = Vector2.ZERO;

@export var flip_h = false;
@export var flip_v = false;

var animation = 0:
	set(value):
		animation = value;
		queue_redraw();
		
var frames = [];
var xmlList = {};

func reload():
	frames.clear();
	xmlList.clear();
	
	var fileParser = XMLParser.new();
	fileParser.open(xmlPath);
	
	if fileParser.read() != OK:
		print("error in %s.xml"%[xmlPath]);
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
			
		var anim_name = fileParser.get_named_attribute_value_safe("name");
		if fileParser.get_named_attribute_value_safe("name") != "":
			var animArray = [];
			for i in fileParser.get_named_attribute_value_safe("name"):
				animArray.append(i);
				
			var curFrame = ''.join(animArray).substr(0, animArray.size() - 4);
			if !xmlList.has(curFrame):
				xmlList[curFrame] = [];
				
			xmlList[curFrame].append(list);
			
			if !frames.has(curFrame):
				frames.append(curFrame);
				
	notify_property_list_changed();
	queue_redraw();
	
var timer = 0.0;
func _process(delta: float) -> void:
	scale.x = abs(scale.x) * (-1 if flip_h else 1);
	scale.y = abs(scale.y) * (-1 if flip_v else 1);
	
	if frames.is_empty():
		return;
		
	if playing:
		timer += delta*fps;
		if timer > get_anim_length(frames[animation])-1:
			timer = 0 if loop else get_anim_length(frames[animation])-1;
			
		frame = int(timer);
		queue_redraw();
		
func get_frame_info(anim) -> Array:
	if xmlList.has(anim):
		return xmlList[anim];
		
	return [];
	
func get_anim_length(anim):
	if xmlList.has(anim):
		return len(xmlList[anim]);
		
func _draw() -> void:
	if frames.is_empty():
		return;
		
	var currentFrame = get_frame_info(frames[animation])[frame];
	
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
		
	var draw_pos = offset;
	if sprite_centered:
		draw_pos -= Vector2(
			currentFrame["frameWidth"] / 2.0,
			currentFrame["frameHeight"] / 2.0
		);
	if currentFrame["rotated"]:
		draw_set_transform(draw_pos + Vector2(0, currentFrame["frameHeight"] - currentFrame["frameY"]), -PI / 2.0, Vector2.ONE);
		draw_texture(atlasTexture, Vector2.ZERO);
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE);
	else:
		draw_texture(atlasTexture, draw_pos);
		
func _get_property_list():
	var properties: Array[Dictionary] = [];
	
	properties.append({
		"name": "animation",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(xmlList.keys()),
		"usage": PROPERTY_USAGE_DEFAULT
	});
	
	return properties;
	
func play(anim):
	if !xmlList.has(anim):
		return;
		
	animation = xmlList.keys().find(anim);
	playing = true;
	timer = 0;
	frame = 0;
	queue_redraw();

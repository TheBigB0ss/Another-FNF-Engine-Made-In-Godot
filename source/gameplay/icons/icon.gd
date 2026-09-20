class_name Icon extends Node2D

@export var enable = true;
@export var flip_h = false;

var cur_iconAnim = "";

var icon_frames = "";
var icon_char = "";
var end_transition = false;

var icon_data = {};
var iconAnimList = [];
var iconPosesList = [];

var icon_scale = Vector2.ZERO;

var is_animated = false;
var icon_sprite:Sprite2D;
var icon_animated:AnimatedSprite2D;

func init_icon(parent, path, is_opponent, animated, icon_position):
	var new_icon = Icon.new();
	
	new_icon.is_animated = animated;
	new_icon.position = icon_position;
	new_icon.flip_h = !is_opponent;
	
	if animated:
		new_icon.icon_frames = "assets/images/icons/animated/%s/%s.res"%[path, path];
		new_icon.icon_char = path;
		new_icon.reload_animated_icon();
	else:
		new_icon.reload_icon(path);
		
	parent.add_child(new_icon);
	
	return new_icon;
	
func _ready() -> void:
	icon_scale = scale;
	
	Conductor.new_beat.connect(beat_hit);
	
func _process(delta: float) -> void:
	if !enable:
		return;
		
	if GlobalOptions.updated_icon != "disabled":
		match GlobalOptions.updated_icon:
			"kade icon":
				scale.x = lerp(icon_scale.x, scale.x, clamp(1.0 - delta * 30.0, 0.0, 1.0));
				scale.y = scale.x;
			"funny icon":
				rotation_degrees = lerp(rotation_degrees, 0.0, 1.0 - exp(-8.0 * delta));
				scale = scale.lerp(icon_scale, 1.0 - exp(-8.0 * delta));
			_:
				scale = scale.lerp(icon_scale, 1.0 - exp(-8.0 * delta));
				
func play_icon_anim(anim):
	if is_animated:
		var cur_anim = anim;
		
		if anim != "win" && anim != "lose" && anim != "transition":
			end_transition = false;
			
		if anim in ["win", "lose"] && !end_transition:
			cur_anim = "transition";
			
		cur_iconAnim = anim;
		
		for i in iconAnimList.size():
			if iconAnimList[i] == cur_anim:
				icon_animated.play(iconPosesList[i]);
				break;
				
		return;
		
	if !icon_sprite.texture:
		return;
		
	var tex_width = icon_sprite.texture.get_width();
	if tex_width <= 150:
		icon_sprite.frame = 0;
		return;
		
	match anim:
		"lose":
			icon_sprite.frame = 1;
		"win":
			icon_sprite.frame = 0 if tex_width <= 300 else 2;
		"idle":
			icon_sprite.frame = 0;
			
	cur_iconAnim = anim;
	
func set_icon_hframes():
	if !icon_sprite.texture:
		return;
		
	var tex_width = icon_sprite.texture.get_width();
	if tex_width <= 150:
		icon_sprite.hframes = 1;
	elif tex_width <= 300:
		icon_sprite.hframes = 2;
	else:
		icon_sprite.hframes = 3;
		
func beat_hit(beat):
	if !enable:
		return;
		
	match GlobalOptions.updated_icon:
		"default":
			scale = icon_scale * 1.15;
		"kade icon":
			scale = icon_scale * 1.2;
		"funny icon":
			scale = Vector2(1.15, 0.5);
			rotation_degrees = 15.0 if beat % 2 == 0 else -15.0;
			
func reload_icon(icon, playIconAnim = ""):
	is_animated = false;
	
	if icon_animated:
		icon_animated.queue_free();
		icon_animated = null;
		
	if icon_sprite == null:
		icon_sprite = Sprite2D.new();
		add_child(icon_sprite);
		
	icon_sprite.flip_h = flip_h;
	icon_sprite.texture = load("res://assets/images/icons/icon-%s.png"%[icon]);
	set_icon_hframes();
	
	if playIconAnim != "":
		play_icon_anim(playIconAnim);
		
func reload_animated_icon(playIconAnim = ""):
	is_animated = true;
	
	if icon_sprite:
		icon_sprite.queue_free();
		icon_sprite = null;
		
	if icon_animated == null:
		icon_animated = AnimatedSprite2D.new();
		add_child(icon_animated);
		
		icon_animated.animation_finished.connect(func():
			var transition_anim = get_icon_animation("transition");
			
			if transition_anim != "" && icon_animated.animation == transition_anim:
				end_transition = true;
				play_icon_anim(cur_iconAnim);
		);
		
	icon_animated.flip_h = flip_h;
	icon_animated.sprite_frames = load("res://%s"%[icon_frames]);
	
	var jsonFile = FileAccess.open("res://assets/images/icons/animated/%s/%s.json"%[icon_char, icon_char], FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	icon_data = jsonData.get_data();
	jsonFile.close();
	
	iconAnimList.clear();
	iconPosesList.clear();
	
	if icon_data.has("IconPoses"):
		for i in icon_data["IconPoses"].size():
			iconAnimList.append(icon_data["IconPoses"][i]["Anim"]);
			iconPosesList.append(icon_data["IconPoses"][i]["Name"]);
			
	if playIconAnim != "":
		play_icon_anim(playIconAnim);
		
func get_icon_animation(anim):
	for i in iconAnimList.size():
		if iconAnimList[i] == anim:
			return iconPosesList[i];
			
	return "";
	
func get_icon_color():
	if !icon_sprite.texture or is_animated:
		return Color.WHITE;
		
	var colorImg = icon_sprite.texture.get_image();
	var frame_width = icon_sprite.texture.get_width() / icon_sprite.hframes;
	var frame_height = icon_sprite.texture.get_height();
	
	var final_color = Color.WHITE;
	var color_amount = 0;
	var colors = {};
	
	for i in frame_height:
		for j in frame_width:
			var color = colorImg.get_pixel(i, j);
			
			if color.a < 1 or (color.r < 0.1 && color.g < 0.1 && color.b < 0.1):
				continue;
				
			var color_key = str(int(color.r * 255), " ", int(color.g * 255), " ", int(color.b * 255));
			
			if !colors.has(color_key):
				colors[color_key] = {
					"amount": 0,
					"color": color
				};
				
			if colors.has(color_key):
				colors[color_key]["amount"] += 1;
				
	for i in colors:
		if color_amount < colors[i]["amount"]:
			color_amount = colors[i]["amount"];
			final_color = colors[i]["color"];
			
	return final_color;
	
func get_rect():
	if is_animated:
		if icon_animated == null or icon_animated.sprite_frames == null:
			return Rect2();
			
		var frame_texture = icon_animated.sprite_frames.get_frame_texture(icon_animated.animation, icon_animated.frame);
		if frame_texture == null:
			return Rect2();
			
		var size = frame_texture.get_size();
		return Rect2(-size / 2.0, size);
	else:
		if icon_sprite == null or icon_sprite.texture == null:
			return Rect2();
			
		#var size = icon_sprite.texture.get_size() / Vector2(icon_sprite.hframes, icon_sprite.vframes);
		#return Rect2(-size / 2.0, size);
		
		return icon_sprite.get_rect();

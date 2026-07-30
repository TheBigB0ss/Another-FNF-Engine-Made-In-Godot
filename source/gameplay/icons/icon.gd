class_name Icon extends Sprite2D

@export var enable = true;

func init_icon(parent, path, is_opponent, is_animated, icon_position):
	var new_icon = AnimatedIcon.new() if is_animated else Icon.new();
	
	if is_animated:
		new_icon.icon_frames = "assets/images/icons/animated/%s/%s.res"%[path, path];
		new_icon.icon_char = path;
	else:
		new_icon.reload_icon(path);
		
	new_icon.position = icon_position;
	new_icon.flip_h = !is_opponent;
	parent.add_child(new_icon);
	
	return new_icon;
	
func _ready() -> void:
	Conductor.new_beat.connect(beat_hit);
	
func _process(delta: float) -> void:
	if !enable:
		return;
		
	scale = lerp(scale, Vector2(1.0, 1.0), 1.0 - exp(-8.0 * delta));
	
func play_icon_anim(anim):
	if !texture:
		return;
		
	var tex_width = texture.get_width();
	if tex_width <= 150:
		frame = 0;
		return;
		
	match anim:
		"lose":
			frame = 1;
		"win":
			frame = 0 if tex_width <= 300 else 2;
		"idle":
			frame = 0;
			
func set_icon_hframes():
	if !texture:
		return;
		
	var tex_width = texture.get_width();
	if tex_width <= 150:
		hframes = 1;
	elif tex_width <= 300:
		hframes = 2;
	else:
		hframes = 3;
		
func beat_hit(_beat):
	if !enable:
		return;
		
	if GlobalOptions.updated_icon != "disabled":
		scale = Vector2(1.15, 1.15);
		
func reload_icon(icon, playIconAnim = ""):
	texture = load("res://assets/images/icons/icon-%s.png"%[icon]);
	set_icon_hframes();
	if playIconAnim == "":
		return;
		
	play_icon_anim(playIconAnim);
	
func get_icon_color():
	if !texture:
		return Color.WHITE;
		
	var colorImg = texture.get_image();
	var frame_width = texture.get_width() / hframes;
	var frame_height = texture.get_height();
	
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

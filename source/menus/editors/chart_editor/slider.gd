@tool
class_name BarSlider extends Control

var scroll_ball = Sprite2D.new();
var texture_bar = TextureProgressBar.new();

@export var newMinVal = 0.0:
	set(val):
		if newMinVal != val:
			newMinVal = val;
			if texture_bar:
				texture_bar.min_value = val;
				
@export var newMaxVal = 10.0:
	set(val):
		if newMaxVal != val:
			newMaxVal = val;
			if texture_bar:
				texture_bar.max_value = val;
				
@export var isVertical = false:
	set(value):
		if isVertical == value:
			return;
			
		isVertical = value;
		
		if texture_bar == null or scroll_ball == null:
			return;
			
		texture_bar.size = Vector2(
			size.y if isVertical else size.x,
			size.x if isVertical else size.y
		);
		
		texture_bar.rotation_degrees = 90.0 if isVertical else 0.0;
		scroll_ball.rotation_degrees = 0.0 if isVertical else 90.0;
		
@export var enable = true;

var value = 0.0;

signal value_changed(value);

func _ready() -> void:
	texture_bar.min_value = newMinVal;
	texture_bar.max_value = newMaxVal;
	
	texture_bar.tint_under = Color.BLACK;
	texture_bar.texture_under = preload("res://assets/images/hud/timeBar.png");
	texture_bar.texture_progress = preload("res://assets/images/hud/timeBar.png");
	texture_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT;
	texture_bar.size = Vector2(
		size.y if isVertical else size.x,
		size.x if isVertical else size.y
	);
	if isVertical:
		texture_bar.rotation_degrees = 90.0;
		
	add_child(texture_bar);
	
	scroll_ball.texture = preload("res://assets/images/editors/cursor-scroll.png");
	scroll_ball.scale = Vector2(0.45, 0.45);
	if !isVertical:
		scroll_ball.rotation_degrees = 90.0;
		
	add_child(scroll_ball);
	
var og_scale = Vector2(0.45, 0.45);
var target_scale = Vector2(0.50, 0.50);

var scroll_ball_scale = Vector2.ZERO;
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return;
		
	scroll_ball_scale = og_scale;
	if mouse_inside(scroll_ball) && enable:
		scroll_ball_scale = target_scale;
		
		if Input.is_action_pressed("mouse_click"):
			var mouse = get_local_mouse_position();
			var new_value = 0.0;
			
			if !isVertical:
				new_value = remap(mouse.x, texture_bar.position.x, texture_bar.position.x + texture_bar.size.x, newMinVal, newMaxVal);
			else:
				new_value = remap(mouse.y, texture_bar.position.y, texture_bar.position.y + texture_bar.size.x, newMinVal, newMaxVal);
				
			new_value = clamp(new_value, newMinVal, newMaxVal);
			
			if value != new_value:
				value = new_value;
				value_changed.emit(value);
				
	value = clamp(value, newMinVal, newMaxVal);
	
	var percent = remap(value, newMinVal, newMaxVal, 0.0, 1.0);
	if !isVertical:
		scroll_ball.position.x = percent * texture_bar.size.x;
	else:
		scroll_ball.position.y = percent * texture_bar.size.x;
		
	texture_bar.value = value;
	
	scroll_ball.scale = lerp(scroll_ball.scale, scroll_ball_scale, 1.0 - exp(-12.0 * delta));
	
func mouse_inside(spr):
	var mouse = get_global_mouse_position();
	var spr_size = spr.get_texture().get_size() * spr.scale;
	return (
		mouse.x > spr.global_position.x - spr_size.x / 2.0
		&& mouse.x < spr.global_position.x + spr_size.x / 2.0
		&& mouse.y > spr.global_position.y - spr_size.y / 2.0
		&& mouse.y < spr.global_position.y + spr_size.y / 2.0
	);

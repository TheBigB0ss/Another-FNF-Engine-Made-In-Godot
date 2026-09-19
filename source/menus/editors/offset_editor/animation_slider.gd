@tool
class_name AnimationSlider extends BarSlider

var left_arrow = Sprite2D.new();
var right_arrow = Sprite2D.new();

var last_frame_arrow = Sprite2D.new();
var first_frame_arrow = Sprite2D.new();

func _ready() -> void:
	isVertical = false;
	super._ready();
	
	texture_bar.texture_under = preload("res://assets/images/editors/offset_ui/ui_bar.png");
	texture_bar.texture_progress = preload("res://assets/images/editors/offset_ui/ui_bar.png");
	
	scroll_ball.texture = preload("res://assets/images/editors/offset_ui/ui_pointer.png");
	scroll_ball.position.y = texture_bar.position.y - 30;
	scroll_ball.rotation_degrees = 360;
	
	left_arrow.texture = preload("res://assets/images/editors/offset_ui/UI_RIGHT.png");
	right_arrow.texture = preload("res://assets/images/editors/offset_ui/UI_LEFT.png");
	last_frame_arrow.texture = preload("res://assets/images/editors/offset_ui/UI_RIGHT_WALL.png");
	first_frame_arrow.texture = preload("res://assets/images/editors/offset_ui/UI_LEFT_WALL.png");
	
	add_child(left_arrow);
	add_child(right_arrow);
	add_child(last_frame_arrow);
	add_child(first_frame_arrow);
	
	var center_y = (texture_bar.position.y + texture_bar.size.y / 2.0) + 30;
	left_arrow.position = Vector2(texture_bar.position.x - 55, center_y);
	right_arrow.position = Vector2(texture_bar.position.x + texture_bar.size.x + 280, center_y);
	
	first_frame_arrow.position = Vector2(left_arrow.position.x - 155, center_y);
	last_frame_arrow.position = Vector2(right_arrow.position.x + 155, center_y);
	
	og_scale = Vector2(1.30, 1.30);
	target_scale = Vector2(1.70, 1.70);
	
func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		if Input.is_action_just_pressed("mouse_click"):
			if mouse_inside(left_arrow):
				value = max(value - 1, newMinVal);
				value_changed.emit(value);
				
			elif mouse_inside(right_arrow):
				value = min(value + 1, newMaxVal);
				value_changed.emit(value);
				
			elif mouse_inside(last_frame_arrow):
				value = newMaxVal;
				value_changed.emit(value);
				
			elif mouse_inside(first_frame_arrow):
				value = newMinVal;
				value_changed.emit(value);
				
	super._process(delta);
	

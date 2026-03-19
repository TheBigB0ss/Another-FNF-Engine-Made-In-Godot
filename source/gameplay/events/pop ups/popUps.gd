extends Node2D

@onready var bar = $"pop up stuff/Bar";
@onready var x_button = $'pop up stuff/XButton';
@onready var pop_up = $'pop up stuff/pop up';

@onready var all_stuff = $"pop up stuff";

var deleted = false;

func _ready():
	deleted = false;
	
	all_stuff.scale = Vector2(0,0);
	
	var tw = get_tree().create_tween();
	tw.tween_property(all_stuff, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	all_stuff.pivot_offset = Vector2(585, 335);
	all_stuff.position = Vector2(randf_range(160, 420), randf_range(140, 240));
	
	pop_up.texture = load("res://assets/images/pop ups/pop up%s.png"%[int(randf_range(1, 5))]);
	
func _process(delta):
	if all_stuff != null && !deleted:
		if !Input.is_action_just_pressed("mouse_click"):
			return;
			
		if mouse_inside_the_X():
			delete_pop_up();
			
func mouse_inside_the_X():
	var mouse = get_global_mouse_position();
	if get_global_mouse_position().x >= x_button.global_position.x-30 && get_global_mouse_position().x < x_button.global_position.x+30 && get_global_mouse_position().y >= x_button.global_position.y-30 && get_global_mouse_position().y < x_button.global_position.y+30:
		return true;
		
	return false;
	
func delete_pop_up():
	deleted = true;
	var tw = get_tree().create_tween();
	tw.tween_property(all_stuff, "scale", Vector2(0, 0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(all_stuff.queue_free);

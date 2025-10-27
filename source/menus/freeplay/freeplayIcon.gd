class_name freeplayIcon extends Sprite2D

var alphabet = Alphabet.new();

var new_x = 0.0;
var new_y = 0.0;

func load_icon(path):
	var alphabet_width = 0.0;
	var icon = Sprite2D.new();
	icon.texture = load("res://assets/images/icons/icon-%s.png"%[path]);
	
	if icon.texture.get_width() <= 300:
		icon.hframes = 2;
	if icon.texture.get_width() >= 450:
		icon.hframes = 3;
	if icon.texture.get_width() <= 150:
		icon.hframes = 1;
		
	var frame_texture = alphabet.global_anim.sprite_frames.get_frame_texture(alphabet.global_anim.animation, alphabet.global_anim.frame).get_width();
	var frame_widht = frame_texture*alphabet.global_anim.sprite_frames.get_frame_count(alphabet.global_anim.animation)
	
	icon.position = Vector2(alphabet.global_anim.position.x + frame_widht + 10, alphabet.position.y + new_y)
	add_child(icon)

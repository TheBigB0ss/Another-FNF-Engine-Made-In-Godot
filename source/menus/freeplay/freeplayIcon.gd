class_name freeplayIcon extends Sprite2D

var alphabet = Alphabet.new();

var new_x = 0.0;
var new_y = 0.0;

func load_icon(path):
	var last_letter = alphabet.get_last_letter();
	
	var frame_texture = last_letter.sprite_frames.get_frame_texture(last_letter.animation, last_letter.frame).get_width();
	var frame_widht = frame_texture * last_letter.sprite_frames.get_frame_count(last_letter.animation);
	
	var icon = Icon.new();
	icon = icon.init_icon(self, path, true, false, Vector2(last_letter.position.x + frame_widht, alphabet.position.y + new_y));
	icon.play_icon_anim("idle");
	icon.enable = false;

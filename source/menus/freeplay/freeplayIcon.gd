class_name freeplayIcon extends Sprite2D

var alphabet = Alphabet.new();

var new_x = 0.0;
var new_y = 0.0;

func load_icon(path):
	var frame_texture = alphabet.get_letter(alphabet.letters.size()-1).sprite_frames.get_frame_texture(alphabet.get_letter(alphabet.letters.size()-1).animation, alphabet.get_letter(alphabet.letters.size()-1).frame).get_width();
	var frame_widht = frame_texture*alphabet.get_letter(alphabet.letters.size()-1).sprite_frames.get_frame_count(alphabet.get_letter(alphabet.letters.size()-1).animation)
	
	var icon = Icon.new();
	icon = icon.init_icon(self, path, true, false, Vector2(alphabet.get_letter(alphabet.letters.size()-1).position.x + frame_widht, alphabet.position.y + new_y));
	icon.play_icon_anim("idle");
	icon.enable = false;

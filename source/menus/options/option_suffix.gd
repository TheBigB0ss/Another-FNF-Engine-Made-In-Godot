class_name OptionSuffix extends Node2D

var cur_suffix = 0;
var new_options = [];

var suffix_x = 0;
var suffix_y = 0;

var checkBoxGrp = Node2D.new();
var alphabetGrp = Node2D.new();
var new_alphabetGrp = Node2D.new();

func _ready() -> void:
	add_child(alphabetGrp);
	add_child(new_alphabetGrp);
	add_child(checkBoxGrp);
	
	for i in new_options.size():
		for j in alphabetGrp.get_children():
			alphabetGrp.remove_child(j);
			j.queue_free();
			
		for j in checkBoxGrp.get_children():
			checkBoxGrp.remove_child(j);
			j.queue_free();
			
		var alphabet = Alphabet.new();
		alphabet._creat_word(new_options[i].opt_name);
		alphabetGrp.add_child(alphabet)
		alphabetGrp.position.x = 70;
		
		var frame_texture = alphabet.global_anim.sprite_frames.get_frame_texture(alphabet.global_anim.animation, alphabet.global_anim.frame).get_width();
		var frame_widht = frame_texture*alphabet.global_anim.sprite_frames.get_frame_count(alphabet.global_anim.animation);
		
		suffix_x = alphabet.global_anim.position.x + frame_widht + 10;
		suffix_y = alphabet.position.y;
		
		match typeof(new_options[i].opt_type):
			TYPE_INT, TYPE_FLOAT:
				update_text(str("<", new_options[i].opt_type, ">"), -80, false);
				
			TYPE_ARRAY:
				update_text(str("<", new_options[i].opt_type[new_options[i].cur_option if new_options[i].cur_option != null else 0], ">"), -20, false);
				
			TYPE_STRING:
				suffix_x += 60;
				update_text(str(new_options[i].opt_type));
				
			TYPE_BOOL:
				var check_sprite = AnimatedSprite2D.new();
				check_sprite.sprite_frames = load("res://assets/images/options menu/checkboxThingie.res");
				check_sprite.position = Vector2(suffix_x, suffix_y);
				checkBoxGrp.add_child(check_sprite);
				update_bool_spr(new_options[i].opt_type);
				
	GlobalOptions.updated_options = new_options;
	
func update_text(new_text, new_x = 0, is_bold = true):
	for i in new_alphabetGrp.get_children():
		new_alphabetGrp.remove_child(i);
		i.queue_free();
		
	var alphabet = Alphabet.new();
	alphabet.isBold = is_bold;
	alphabet._clear_word();
	alphabet._creat_word(new_text);
	new_alphabetGrp.add_child(alphabet);
	new_alphabetGrp.position = Vector2(suffix_x+new_x, suffix_y);
	
func update_bool_spr(new_value):
	var check_box_sprite = checkBoxGrp.get_child(cur_suffix);
	
	check_box_sprite.offset.y = -50;
	check_box_sprite.play("Check Box unselecting" if !new_value else "Check Box selecting animation");
	check_box_sprite.connect("animation_finished", Callable(self, "unselected_box").bind(check_box_sprite));
	
func unselected_box(sprite):
	if sprite.animation == "Check Box unselecting":
		sprite.play("Check Box unselected");
		sprite.offset.y = 0;

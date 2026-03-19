class_name OptionSuffix extends Node2D

var cur_suffix = 0;
var new_options = [];

var suffix_x = 0;
var suffix_y = 0;

var checkBoxGrp = Node2D.new();
var alphabetGrp = Node2D.new();
var new_alphabetGrp = Node2D.new();

func _ready() -> void:
	var offSetShit = 0;
	var coolOffset = 140;
	
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
		offSetShit += coolOffset;
		
		var frame_texture = alphabet.global_anim.sprite_frames.get_frame_texture(alphabet.global_anim.animation, alphabet.global_anim.frame).get_width();
		var frame_widht = frame_texture*alphabet.global_anim.sprite_frames.get_frame_count(alphabet.global_anim.animation);
		
		suffix_x = alphabet.global_anim.position.x + frame_widht + 10;
		suffix_y = alphabet.position.y;
		
		match typeof(new_options[i].opt_type):
			TYPE_INT, TYPE_FLOAT:
				update_text(str("<", new_options[i].opt_type, ">"), -80, false);
				
			TYPE_ARRAY:
				update_text(str("<", new_options[i].opt_type[new_options[i].array_val["array value"][0] if new_options[i].array_val != null else 0], ">"), -20, false);
				
			TYPE_STRING:
				suffix_x += 60;
				update_text(str(new_options[i].opt_type));
				
			TYPE_BOOL:
				var check_sprite = AnimatedSprite2D.new();
				check_sprite.sprite_frames = load("res://assets/images/options menu/checkboxThingie.res");
				check_sprite.position.x = suffix_x;
				check_sprite.position.y = suffix_y;
				checkBoxGrp.add_child(check_sprite);
				update_bool_spr(new_options[i].opt_type);
				
	GlobalOptions.updated_options = new_options;
	
func update_bool_spr(new_value):
	if !new_value:
		checkBoxGrp.get_child(cur_suffix).play("Check Box unselecting");
		checkBoxGrp.get_child(cur_suffix).offset.y = -50;
		checkBoxGrp.get_child(cur_suffix).connect("animation_finished", Callable(self, "unselected_box"));
	else:
		checkBoxGrp.get_child(cur_suffix).play("Check Box selecting animation");
		checkBoxGrp.get_child(cur_suffix).offset.y = -50;
		
func update_text(new_text, new_x = 0, is_bold = true):
	for i in new_alphabetGrp.get_children():
		new_alphabetGrp.remove_child(i);
		i.queue_free();
		
	var alphabet = Alphabet.new();
	new_alphabetGrp.position.x = suffix_x+new_x;
	new_alphabetGrp.position.y = suffix_y;
	alphabet.isBold = is_bold;
	alphabet._clear_word();
	alphabet._creat_word(new_text);
	new_alphabetGrp.add_child(alphabet);
	
func unselected_box():
	if checkBoxGrp.get_child(cur_suffix).animation == "Check Box unselecting":
		checkBoxGrp.get_child(cur_suffix).play("Check Box unselected");
		checkBoxGrp.get_child(cur_suffix).offset.y = 0;

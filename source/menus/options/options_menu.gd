extends Node2D

@onready var options_stuff = $'options';
@onready var settings_stuff = $'settings';
@onready var settings = $'settings/new_options';
@onready var description_text = $'settings/Label';
@onready var option_suffix_stuff = $'settings/option_suffix';
@onready var reset_menu = $reset_menu/reset_data_scene;

var coolKeyText = Alphabet;

var offSetShit = 0;
var coolOffset = 140;

var is_on_settings_mode = false;

var new_cur_option = 0;
var cur_option = 0;

var options_array = [];
var new_options_array = [];

var is_on_key_mode = false;
var is_on_reset_menu = false;
var options = {};

func reloadText():
	options = GlobalOptions.set_options();
	
	if !GlobalOptions.pause_options:
		options["offset menu"] = {};
		#options["stage editor"] = {};
		options["clear data"] = {};
		
func _ready() -> void:
	Discord.update_discord_info("options menu", "Is in menus");
	reloadText();
	
	for i in options.keys():
		var alphabet = Alphabet.new();
		alphabet.isCentered = true;
		alphabet._creat_word(i);
		alphabet.position.y += offSetShit;
		alphabet.position.x += 230;
		options_stuff.add_child(alphabet);
		offSetShit += coolOffset;
		options_array.append(i);
		
	options_stuff.position.y = float(480-coolOffset*cur_option);
	settings.position.y = float(480-coolOffset*new_cur_option);
	
	coolKeyText = Alphabet.new();
	coolKeyText.position = Vector2(30, 290);
	$keys.add_child(coolKeyText);
	
	change_option(0);
	
var cur_array_option = 0;
var ignore_key = false;
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && Global.can_use_menus:
			if is_on_settings_mode:
				if ev.keycode in [Global.get_key("escape")] && !ev.echo:
					if !is_on_key_mode:
						new_cur_option = 0;
						$settings/ColorRect.hide();
						is_on_settings_mode = false;
						is_on_key_mode = false;
						settings_stuff.hide();
						options_stuff.show();
						$reset.show();
						
						for i in settings.get_children():
							settings.remove_child(i);
							i.queue_free();
							
						$keys.hide();
						GlobalOptions.updated_options = [];
						
					elif is_on_key_mode:
						is_on_key_mode = false;
						$keys.hide();
						for i in [$settings/ColorRect, $settings/Label]:
							i.show();
							
				if ev.keycode in [Global.get_key("ui_down")] && !ev.echo && !is_on_key_mode:
					change_new_option(1);
					
				if ev.keycode in [Global.get_key("ui_up")] && !ev.echo && !is_on_key_mode:
					change_new_option(-1);
					
				if GlobalOptions.updated_options != []:
					var curSetting = settings.get_child(new_cur_option);
					match typeof(curSetting.opt_type):
						TYPE_INT:
							if ev.keycode in [Global.get_key("ui_right")] && !is_on_key_mode:
								set_change_text(new_cur_option, 1, 250 if curSetting.opt_name == "fps" else 100, 30 if curSetting.opt_name == "fps" else 0);
								
							if ev.keycode in [Global.get_key("ui_left")] && !is_on_key_mode:
								set_change_text(new_cur_option, -1, 250 if curSetting.opt_name == "fps" else 100, 30 if curSetting.opt_name == "fps" else 0);
								
						TYPE_FLOAT:
							if ev.keycode in [Global.get_key("ui_right")] && !is_on_key_mode:
								set_change_text(new_cur_option, 0.1, 1.0, 0.0);
								
							if ev.keycode in [Global.get_key("ui_left")] && !is_on_key_mode:
								set_change_text(new_cur_option, -0.1, 1.0, 0.0);
								
						TYPE_BOOL:
							if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo && !is_on_key_mode:
								set_change_bool(new_cur_option, !curSetting.opt_type);
								
						TYPE_ARRAY:
							if ev.keycode in [Global.get_key("ui_right")] && !is_on_key_mode:
								set_change_array(new_cur_option, 1);
								
							if ev.keycode in [Global.get_key("ui_left")] && !is_on_key_mode:
								set_change_array(new_cur_option, -1);
								
						TYPE_STRING:
							if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo && !is_on_key_mode:
								if curSetting.opt_name.ends_with("Key:"):
									var coolID = GlobalOptions.keys_list[new_cur_option];
									
									$keys.show();
									coolKeyText._creat_word("%s %s"%[curSetting.opt_name, GlobalOptions.keys[coolID][1]]);
									is_on_key_mode = true;
									ignore_key = true;
									for i in [$settings/ColorRect, $settings/Label]:
										i.hide();
										
							if is_on_key_mode:
								if ev.pressed:
									if ignore_key:
										ignore_key = false;
										return;
										
									var coolID = GlobalOptions.keys_list[new_cur_option];
									var new_code = OS.get_keycode_string(ev.keycode).to_lower();
									if GlobalOptions.check_key_bind(ev.keycode, GlobalOptions.keys[coolID][2]):
										Sound.playAudio("cancelMenu", false);
										return;
										
									if InputMap.has_action("ui_%s"%[new_code]):
										InputMap.erase_action("ui_%s"%[new_code]);
										
									InputMap.add_action("ui_%s"%[new_code]);
									InputMap.action_add_event("ui_%s"%[new_code], ev);
									
									GlobalOptions.keys[coolID][0] = ev.keycode;
									GlobalOptions.keys[coolID][1] = new_code;
									
									curSetting.update_text(GlobalOptions.keys[coolID][1]);
									coolKeyText._creat_word("%s %s"%[curSetting.opt_name, GlobalOptions.keys[coolID][1]]);
									GlobalOptions.rebind_keys(coolID, GlobalOptions.keys[coolID][1], GlobalOptions.keys[coolID][0]);
			else:
				if !is_on_reset_menu:
					if ev.keycode in [Global.get_key("ui_down")] && !ev.echo:
						change_option(1);
						
					if ev.keycode in [Global.get_key("ui_up")] && !ev.echo:
						change_option(-1);
						
					if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo:
						choice_shit_opt(options_array[cur_option]);
						
					if ev.keycode in [Global.get_key("escape")] && !ev.echo:
						go_back();
						
					if ev.keycode in [KEY_R] && ev.echo:
						GlobalOptions.reset_settings();
						
func choice_shit_opt(opt):
	match opt:
		"offset menu":
			Global.changeScene("/menus/editors/offset_editor/offset_menu", true, false);
		"stage editor":
			Global.changeScene("/menus/editors/stage_editor/stage_editor", true, false);
		"clear data":
			reset_menu.visible = true;
		_:
			update_options();
			
func set_change_text(cur_opt, change, max, min):
	if settings.get_child(new_cur_option).opt_type + change > max or settings.get_child(new_cur_option).opt_type + change < min:
		return;
		
	settings.get_child(new_cur_option).opt_type += change;
	Sound.playAudio("scrollMenu", false);
	settings.get_child(cur_opt).update_text(str("<", settings.get_child(new_cur_option).opt_type, ">"), -80, false);
	GlobalOptions.get_setting(settings.get_child(new_cur_option).opt_name, settings.get_child(new_cur_option).opt_type);
	
func set_change_bool(cur_opt, value):
	settings.get_child(cur_opt).opt_type = value;
	settings.get_child(cur_opt).update_bool_spr(settings.get_child(cur_opt).opt_type);
	GlobalOptions.get_setting(settings.get_child(cur_opt).opt_name, settings.get_child(cur_opt).opt_type);
	
	match settings.get_child(cur_opt).opt_name:
		"full screen":
			Global.update_windowMode(settings.get_child(cur_opt).opt_type);
		"vsync":
			Global.update_vsync(settings.get_child(cur_opt).opt_type);
			
func set_change_array(cur_opt, change):
	var new_opt = settings.get_child(cur_opt);
	
	new_opt.array_val["array value"][0] += change;
	new_opt.array_val["array value"][0] = wrapi(new_opt.array_val["array value"][0], 0, len(new_opt.opt_type));
	
	new_opt.update_text(str("<", new_opt.opt_type[new_opt.array_val["array value"][0]], ">"), -20, false);
	
	var new_val = new_opt.array_val["value"][new_opt.array_val["array value"][0]];
	var changed_opt = new_opt.array_val["array value"][1];
	
	GlobalOptions.get_setting(changed_opt, new_val);
	GlobalOptions.save_opts_dic(changed_opt, new_opt.array_val["array value"][0]);
	
func update_options():
	reloadText();
	
	for i in settings.get_children():
		i.new_options = [];
		settings.remove_child(i);
		i.queue_free();
		
	is_on_settings_mode = true;
	
	offSetShit = 0;
	coolOffset = 140;
	
	new_options_array = options[options_array[cur_option]].keys();
	
	settings_stuff.show();
	options_stuff.hide();
	$reset.hide();
	$settings/ColorRect.show();
	
	for i in new_options_array:
		var new_option = Option.new();
		new_option.opt_name = i;
		new_option.opt_type = options[options_array[cur_option]][i]["value"];
		new_option.option_new_x = 190;
		new_option.opt_id = len(i);
		new_option.position.y += offSetShit;
		new_option.scale = Vector2(0.8, 0.8);
		
		if options[options_array[cur_option]][i].has('array value'):
			new_option.array_val = options[options_array[cur_option]][i];
		else:
			new_option.array_val = null;
			
		new_option.new_options.append(new_option);
		settings.add_child(new_option);
		
		offSetShit += coolOffset;
		
	change_new_option(0);
	
func go_back():
	if GlobalOptions.pause_options:
		var songDiff = "" if SongData.week_diffs == "" else SongData.week_diffs;
		var song = SongData.week_songs[0];
		
		SongData.loadJson(song, songDiff, SongData.updated_chart);
		Global.changeScene("gameplay/PlayState", true, false);
		GlobalOptions.pause_options = false;
		SongData.restartSong = true;
	else:
		Global.changeScene("menus/main_menu/MainMenu", true, false);
		
func _process(delta):
	is_on_reset_menu = reset_menu.visible;
	options_stuff.position.y = lerp(float(options_stuff.position.y), float(480-coolOffset*cur_option), 0.20);
	settings.position.y = lerp(float(settings.position.y), float(480-coolOffset*new_cur_option), 0.20);
	
func change_option(change):
	cur_option += change;
	Sound.playAudio("scrollMenu", false);
	cur_option = wrapi(cur_option, 0, len(options));
	
	for j in options.size():
		options_stuff.get_child(j).modulate.a = 0.4;
		if j == cur_option:
			options_stuff.get_child(j).modulate.a = 1;
			
func change_new_option(change):
	new_cur_option += change;
	Sound.playAudio("scrollMenu", false);
	new_cur_option = wrapi(new_cur_option, 0, len(new_options_array));
	
	description_text.text = options[options_array[cur_option]][new_options_array[new_cur_option]]["description"];
	
	for j in new_options_array.size():
		settings.get_child(j).modulate.a = 0.4;
		if j == new_cur_option:
			settings.get_child(j).modulate.a = 1;
			

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
		options["cam editor menu"] = {};
		#options["stage editor"] = {};
		options["clear data"] = {};
	else:
		Global.currentOptions = 0;
		get_tree().paused = false;
		
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
	coolKeyText.scale = Vector2(0.75, 0.75);
	coolKeyText.position = Vector2(30, 290);
	$keys.add_child(coolKeyText);
	
	change_option(Global.current_selected["options"]);
	
var cur_array_option = 0;
var ignore_key = false;
func _input(ev):
	if ev is InputEventKey && ev.pressed && Global.can_use_menus:
		if !is_on_settings_mode:
			if !is_on_reset_menu:
				if ev.keycode in [GlobalOptions.get_key("ui_down")] && !ev.echo:
					change_option(1);
					
				if ev.keycode in [GlobalOptions.get_key("ui_up")] && !ev.echo:
					change_option(-1);
					
				if (ev.keycode in [GlobalOptions.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo:
					choice_shit_opt(options_array[cur_option]);
					
				if ev.keycode in [GlobalOptions.get_key("escape")] && !ev.echo:
					go_back();
					
				if ev.keycode in [KEY_R] && ev.echo:
					GlobalOptions.reset_settings();
					
			return;
			
		if ev.keycode in [GlobalOptions.get_key("escape")] && !ev.echo:
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
				
			else:
				is_on_key_mode = false;
				$keys.hide();
				for i in [$settings/ColorRect, $settings/Label]:
					i.show();
					
		if ev.keycode in [GlobalOptions.get_key("ui_down")] && !ev.echo && !is_on_key_mode:
			change_new_option(1);
			
		if ev.keycode in [GlobalOptions.get_key("ui_up")] && !ev.echo && !is_on_key_mode:
			change_new_option(-1);
			
		if GlobalOptions.updated_options != []:
			var curSetting = settings.get_child(new_cur_option);
			var category = options_array[cur_option];
			var opt_name = curSetting.opt_name;
			
			var rightKey = (ev.keycode == GlobalOptions.get_key("ui_right"));
			var leftKey = (ev.keycode == GlobalOptions.get_key("ui_left"));
			var enterKey = (ev.keycode == GlobalOptions.get_key("enter") or ev.keycode == KEY_KP_ENTER);
			
			match typeof(curSetting.opt_type):
				TYPE_INT:
					if is_on_key_mode:
						return;
						
					var min_val = 30 if opt_name == "fps" else 0;
					var max_val = 250 if opt_name == "fps" else 100;
					var dir = int(rightKey) - int(leftKey);
					
					if dir != 0:
						GlobalOptions.change_int_opt(opt_name, category, int(dir), min_val, max_val);
						curSetting.update_text(str("<", int(GlobalOptions.get_value(opt_name, category)), ">"), -80, false);
						
				TYPE_FLOAT:
					if is_on_key_mode:
						return;
						
					var dir = int(rightKey) - int(leftKey);
					if dir != 0:
						GlobalOptions.change_int_opt(opt_name, category, float(dir*0.1), 0.0, 1.0);
						curSetting.update_text(str("<", GlobalOptions.get_value(opt_name, category), ">"), -80, false);
						
				TYPE_BOOL:
					if is_on_key_mode:
						return;
						
					if enterKey && !ev.echo:
						GlobalOptions.change_bool_opt(opt_name, category);
						curSetting.update_bool_spr(GlobalOptions.get_value(opt_name, category));
						
				TYPE_ARRAY:
					if is_on_key_mode:
						return;
						
					var dir = int(rightKey) - int(leftKey);
					if dir != 0:
						GlobalOptions.change_array_opt(opt_name, dir, category);
						curSetting.update_text(str("<", GlobalOptions.get_option_value(opt_name), ">"), -20, false);
						
				TYPE_STRING:
					if (ev.keycode in [GlobalOptions.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo && !is_on_key_mode:
						if curSetting.opt_name.ends_with("Key:"):
							var coolID = GlobalOptions.keys_list[new_cur_option];
							
							$keys.show();
							coolKeyText._creat_word("%s %s"%[curSetting.opt_name, GlobalOptions.keys[coolID][1]]);
							is_on_key_mode = true;
							ignore_key = true;
							for i in [$settings/ColorRect, $settings/Label]:
								i.hide();
								
					if !is_on_key_mode:
						return;
						
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
						
func choice_shit_opt(opt):
	match opt:
		"offset menu":
			Global.changeScene("/menus/editors/offset_editor/offset_menu", true, false);
		"stage editor":
			Global.changeScene("/menus/editors/stage_editor/stage_editor", true, false);
		"cam editor menu":
			Global.changeScene("/menus/editors/cam_editor/cam_editor", true, false);
		"clear data":
			reset_menu.visible = true;
		_:
			update_options();
			
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
	
	var id = 0;
	for i in new_options_array:
		var new_option = Option.new();
		new_option.opt_name = i;
		new_option.opt_type = options[options_array[cur_option]][i]["value"];
		new_option.option_new_x = 190;
		new_option.opt_id = id;
		new_option.cur_option = options[options_array[cur_option]][i].get("ID", null);
		new_option.position.y += offSetShit;
		new_option.scale = Vector2(0.8, 0.8);
		
		new_option.new_options.append(new_option);
		settings.add_child(new_option);
		
		offSetShit += coolOffset;
		id += 1;
		
	change_new_option(0);
	
func go_back():
	if GlobalOptions.pause_options:
		SongData.loadJson(SongData.week_songs[0], SongData.week_diffs, SongData.updated_chart);
		Global.changeScene("gameplay/PlayState", true, false);
		GlobalOptions.pause_options = false;
		SongData.restartSong = true;
	else:
		Global.changeScene("menus/main_menu/MainMenu", true, false);
		
func _process(_delta):
	is_on_reset_menu = reset_menu.visible;
	options_stuff.position.y = lerp(float(options_stuff.position.y), float(480-coolOffset*cur_option), 0.20);
	settings.position.y = lerp(float(settings.position.y), float(480-coolOffset*new_cur_option), 0.20);
	
func change_option(change):
	Sound.playAudio("scrollMenu", false);
	
	cur_option += change;
	cur_option = wrapi(cur_option, 0, len(options));
	Global.currentOptions = cur_option;
	
	for j in options.size():
		options_stuff.get_child(j).modulate.a = 0.4;
		if j == cur_option:
			options_stuff.get_child(j).modulate.a = 1;
			
func change_new_option(change):
	Sound.playAudio("scrollMenu", false);
	
	new_cur_option += change;
	new_cur_option = wrapi(new_cur_option, 0, len(new_options_array));
	
	description_text.text = options[options_array[cur_option]][new_options_array[new_cur_option]]["description"];
	
	for j in new_options_array.size():
		settings.get_child(j).modulate.a = 0.4;
		if j == new_cur_option:
			settings.get_child(j).modulate.a = 1;
			

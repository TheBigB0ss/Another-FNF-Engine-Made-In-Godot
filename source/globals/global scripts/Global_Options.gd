extends Node

var updated_options = [];

var settingsJson = {};
var pause_options = false;
var down_scroll = false;
var middle_scroll = false;
var restart_action = false;
var hide_hud = false;
var fps = 60;
var uncap_fps = false;
var vsync = true;
var ghost_tapping = true;
var low_quality = false;
var time_bar_alpha = 1.0;
var health_bar_alpha = 1.0;
var full_screen = false;
var volume = 1;
var isUsingBot = false;
var playMissSound = true;

var debugTextMode = "simple";
var updated_pause_music = "pause song";
var updated_hud = "new hud";
var updated_cam = "normal";
var updated_icon = "default";
var rating_mode = "hud element";
var timeBar_mode = "default";
var idleMode = "beat";

var use_shader = true;
var show_splashes = true;
var show_songCard = true;
var screen_zoom = true;
var show_ratingLabel = false;

var keys_list = [];
var keys = {
	"left": [KEY_LEFT, "left", 1],
	"down": [KEY_DOWN, "down", 1],
	"up": [KEY_UP, "up", 1],
	"right": [KEY_RIGHT, "right", 1],
	"ui_left": [KEY_LEFT, "left", 2],
	"ui_down": [KEY_DOWN, "down", 2],
	"ui_up": [KEY_UP, "up", 2],
	"ui_right": [KEY_RIGHT, "right", 2],
	"enter": [KEY_ENTER, "enter", 2],
	"escape": [KEY_ESCAPE, "escape", 2],
	"equal": [KEY_EQUAL, "equal", 3],
	"minus": [KEY_MINUS, "minus", 3],
	"7": [KEY_7, "7", 3],
	"F11": [KEY_F11, "F11", 3]
};

var ratings_positions = {
	"rating": [],
	"combo": [],
	"nums": []
};

signal ghost_tapping_miss(note);

func _ready():
	#reset_settings();
	load_settings();
	
	for i in range(0, 1):
		for j in keys.keys():
			keys_list.append(j);
			
	if !settingsJson.has("version") or settingsJson["version"] != 7:
		reset_settings();
		
	apply_changes();
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if GlobalOptions.full_screen else DisplayServer.WINDOW_MODE_WINDOWED);
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if GlobalOptions.vsync else DisplayServer.VSYNC_DISABLED);
	
func update_vsync(toggle): DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggle else DisplayServer.VSYNC_DISABLED);
func update_windowMode(toggle): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggle else DisplayServer.WINDOW_MODE_WINDOWED);

func save_settings():
	var new_jsonFile = FileAccess.open("user://Settings.json", FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(settingsJson));
	new_jsonFile.close();
	apply_changes();
	
func load_settings():
	if FileAccess.file_exists("user://Settings.json"):
		var new_jsonFile = FileAccess.open("user://Settings.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		settingsJson = jsonData.get_data();
		new_jsonFile.close();
	else:
		reset_settings();
		
func reset_settings():
	settingsJson = {
		"version": 7,
		"meta":{
			"rating_pos": [635, 235],
			"combo_pos": [695, 285],
			"nums_pos": [464, 293],
			"volume": 1
		},
		"graphics": {
			"fps": int(60),
			"uncap fps": false,
			"vsync": true,
			"fullscreen": false,
			"low quality": false,
			"use shader": true,
			"debug text mode": "simple"
		},
		"gameplay": {
			"down scroll": false,
			"middle scroll": false,
			"ghost tapping": true,
			"r to restart": false,
			"play miss sound": true,
			"pause music": "pause song",
			"camera mode": "normal",
			"idle mode": "step"
		},
		"visual": {
			"hud mode": "new hud",
			"rating mode": "hud element",
			"icon type": "default",
			"time bar type": "default",
			"hide hud": false,
			"screen zoom": true,
			"show splashes": true,
			"show song card": true,
			"show rating label": false,
			"health bar alpha": 1.0
		},
		"keys":{
			"left": [KEY_LEFT, "left", 1],
			"down": [KEY_DOWN, "down", 1],
			"up": [KEY_UP, "up", 1],
			"right": [KEY_RIGHT, "right", 1],
			"ui_left": [KEY_LEFT, "left", 2],
			"ui_down": [KEY_DOWN, "down", 2],
			"ui_up": [KEY_UP, "up", 2],
			"ui_right": [KEY_RIGHT, "right", 2],
			"enter": [KEY_ENTER, "enter", 2],
			"escape": [KEY_ESCAPE, "escape", 2],
			"equal": [KEY_EQUAL, "equal", 3],
			"minus": [KEY_MINUS, "minus", 3],
			"7": [KEY_7, "7", 3],
			"F11": [KEY_F11, "F11", 3]
		},
		"options": {
			"pause music": {
				"list": ["pause song", "breakfast"],
				"index": 0
			},
			"hud mode": {
				"list": ["new hud", "classic hud"],
				"index": 0
			},
			"camera mode": {
				"list": ["normal", "smooth"],
				"index": 0
			},
			"icon type": {
				"list": ["default", "disabled"],
				"index": 0
			},
			"rating mode": {
				"list": ["hud element", "game element"],
				"index": 0
			},
			"time bar type": {
				"list": ["default", "time left", "time elapsed", "disable"],
				"index": 0
			},
			'debug text mode':{
				"list": ["simple", "complex", "disable"],
				"index": 0
			},
			'idle mode':{
				"list": ["beat", "step"],
				"index": 0
			}
		}
	};
	save_settings();
	
func update_keys():
	for i in keys.keys():
		var ev = InputEventKey.new();
		ev.keycode = keys[i][0];
		if InputMap.has_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]):
			InputMap.erase_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]);
			
		InputMap.add_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]);
		InputMap.action_add_event("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()], ev);
		
func check_key_bind(key_id, key_index):
	for i in keys.keys():
		if keys[i][0] == key_id && keys[i][2] == key_index:
			return true;
			
	return false;
	
func get_key(key_code):
	var ev = InputEventKey.new();
	ev.keycode = keys[key_code][0];
	return ev.keycode;
	
func apply_changes():
	down_scroll = settingsJson["gameplay"]["down scroll"];
	middle_scroll = settingsJson["gameplay"]["middle scroll"];
	ghost_tapping = settingsJson["gameplay"]["ghost tapping"];
	restart_action = settingsJson["gameplay"]["r to restart"];
	playMissSound = settingsJson["gameplay"]["play miss sound"];
	idleMode = settingsJson["gameplay"]["idle mode"];
	
	vsync = settingsJson["graphics"]["vsync"];
	low_quality = settingsJson["graphics"]["low quality"];
	fps = int(settingsJson["graphics"]["fps"]);
	uncap_fps = settingsJson["graphics"]["uncap fps"];
	full_screen = settingsJson["graphics"]["fullscreen"];
	use_shader = settingsJson["graphics"]["use shader"];
	debugTextMode = settingsJson["graphics"]["debug text mode"];
	
	hide_hud = settingsJson["visual"]["hide hud"];
	#time_bar_alpha = settingsJson["visual"]["time bar alpha"];
	timeBar_mode = settingsJson["visual"]["time bar type"];
	health_bar_alpha = settingsJson["visual"]["health bar alpha"];
	show_splashes = settingsJson["visual"]["show splashes"];
	show_songCard = settingsJson["visual"]["show song card"];
	screen_zoom = settingsJson["visual"]["screen zoom"];
	show_ratingLabel = settingsJson["visual"]["show rating label"];
	
	updated_hud = settingsJson["visual"]["hud mode"];
	rating_mode = settingsJson["visual"]["rating mode"];
	updated_icon = settingsJson["visual"]["icon type"];
	
	updated_pause_music = settingsJson["gameplay"]["pause music"];
	updated_cam = settingsJson["gameplay"]["camera mode"];
	
	volume = settingsJson["meta"]["volume"];
	
	ratings_positions["rating"] = settingsJson["meta"]["rating_pos"];
	ratings_positions["combo"] = settingsJson["meta"]["combo_pos"];
	ratings_positions["nums"] = settingsJson["meta"]["nums_pos"];
	
	keys = settingsJson["keys"];
	
	Engine.max_fps = fps if !uncap_fps else 0;
	
	update_keys();
	
func get_option_value(opt_name):
	return settingsJson["options"][opt_name]["list"][settingsJson["options"][opt_name]["index"]];
	
func get_value(opt_name, category):
	return settingsJson[category][opt_name];
	
func set_setting(setting, category, value):
	settingsJson[category][setting] = value;
	apply_changes();
	save_settings();
	
func save_opts_dic(opt, value):
	settingsJson["options"][opt]["index"] = value;
	apply_changes();
	save_settings();
	
func rebind_keys(key_selected, new_key, key_value):
	settingsJson["keys"][key_selected][0] = key_value;
	settingsJson["keys"][key_selected][1] = new_key;
	
	save_settings();
	
func change_array_opt(opt_name, change, category):
	settingsJson["options"][opt_name]["index"] += change;
	settingsJson["options"][opt_name]["index"] = wrapi(settingsJson["options"][opt_name]["index"], 0, len(settingsJson["options"][opt_name]["list"]));
	
	var newId = settingsJson["options"][opt_name]["index"];
	var new_value = settingsJson["options"][opt_name]["list"][newId];
	
	set_setting(opt_name, category, new_value);
	save_opts_dic(opt_name, settingsJson["options"][opt_name]["index"]);
	
func change_bool_opt(opt_name, category):
	var value = settingsJson[category][opt_name];
	value = !value;
	
	set_setting(opt_name, category, value);
	
	match opt_name:
		"fullscreen":
			update_windowMode(value);
		"vsync":
			update_vsync(value);
			
func change_int_opt(opt_name, category, change, min_value, max_value):
	settingsJson[category][opt_name] += change;
	settingsJson[category][opt_name] = clamp(settingsJson[category][opt_name], min_value, max_value);
	apply_changes();
	save_settings();
	
func set_options():
	return {
		"graphics": {
			"fps": {
				"value": int(settingsJson["graphics"]["fps"]),
				"description": "change FPS (won't work if the uncap fps is enable)"
			},
			"uncap fps": {
				"value": settingsJson["graphics"]["uncap fps"],
				"description": "uncap fps?"
			},
			"debug text mode":{
				"value": settingsJson["options"]["debug text mode"]["list"],
				"description": "select the debug text mode"
			},
			"vsync": {
				"value": settingsJson["graphics"]["vsync"],
				"description": "disable vsync?"
			},
			"low quality": {
				"value": settingsJson["graphics"]["low quality"],
				"description": "disable some elements for better performance"
			},
			"use shader": {
				"value": settingsJson["graphics"]["use shader"],
				"description": "disable shaders?"
			},
			"fullscreen": {
				"value": settingsJson["graphics"]["fullscreen"],
				"description": "full screen mode"
			}
		},
		"controls": {
			"Left Key:":{
				"value": keys["left"][1], 
				"description": "change left key"
			},
			"Down Key:":{
				"value": keys["down"][1], 
				"description": "change down key"
			},
			"Up Key:":{
				"value": keys["up"][1],
				 "description": "change up key"
			},
			"Right Key:":{
				"value": keys["right"][1], 
				"description": "change right key"
			},
			"Ui Left Key:":{
				"value": keys["ui_left"][1], 
				"description": "change menu left key"
			},
			"Ui Down Key:":{
				"value": keys["ui_down"][1],
				"description": "change menu down key"
			},
			"Ui Up Key:":{
				"value": keys["ui_up"][1],
				"description": "change menu up key"
			},
			"Ui Right Key:":{
				"value": keys["ui_right"][1], 
				"description": "change menu right key"
			},
			"Ui Enter Key:":{
				"value": keys["enter"][1], 
				"description": "change enter key"
			},
			"Ui Esc Key:":{
				"value": keys["escape"][1], 
				"description": "change escape key"
			},
			"Volume Up Key:":{
				"value": keys["equal"][1], 
				"description": "change volume up key"
			},
			"Volume Down Key:":{
				"value": keys["minus"][1], 
				"description": "change volume down key"
			},
			"Chart Key:":{
				"value": keys["7"][1], 
				"description": "change chart key"
			},
			"Screenshot Key:":{
				"value": keys["F11"][1],
				"description": "change screenshot key"
			}
		},
		"visual": {
			"hud mode": {
				"value": settingsJson["options"]["hud mode"]["list"],
				"description": "choice hud mode",
				"ID": settingsJson["options"]["hud mode"]["index"]
			},
			"rating mode": {
				"value": settingsJson["options"]["rating mode"]["list"],
				"description": "choose how the rating will behave on the game screen",
				"ID": settingsJson["options"]["rating mode"]["index"]
			},
			"icon type": {
				"value": settingsJson["options"]["icon type"]["list"],
				"description": "icon style",
				"ID": settingsJson["options"]["icon type"]["index"]
			},
			"time bar type":{
				"value": settingsJson["options"]["time bar type"]["list"],
				"description": "time bar mode",
				"ID": settingsJson["options"]["time bar type"]["index"]
			},
			"show splashes":{
				"value": settingsJson["visual"]["show splashes"],
				"description": "show note splashes"
			},
			"show song card":{
				"value": settingsJson["visual"]["show song card"],
				"description": "show song name"
			},
			"show rating label":{
				"value": settingsJson["visual"]["show rating label"],
				"description": "enable rating label"
			},
			"hide hud":{
				"value": settingsJson["visual"]["hide hud"], 
				"description": "hide your hud"
			},
			"screen zoom":{
				"value": settingsJson["visual"]["screen zoom"],
				"description": "disable camera zoom"
			},
			"health bar alpha": {
				"value": settingsJson["visual"]["health bar alpha"],
				"description": "health bar opacity"
			}
		},
		"gameplay": {
			"ghost tapping": {
				"value": settingsJson["gameplay"]["ghost tapping"],
				"description": "disable ghost tapping?"
			},
			"down scroll": {
				"value": settingsJson["gameplay"]["down scroll"],
				"description": "down scroll mode"
			},
			"middle scroll": {
				"value": settingsJson["gameplay"]["middle scroll"],
				"description": "middle scroll mode"
			},
			"r to restart": {
				"value": settingsJson["gameplay"]["r to restart"],
				"description": "press R for an instant and painless death"
			},
			"play miss sound": {
				"value": settingsJson["gameplay"]["play miss sound"],
				"description": "play a sound clue when you missed a note"
			},
			"idle mode": {
				"value": settingsJson["options"]["idle mode"]["list"],
				"description": "select how you want the character to return to idle",
				"ID": settingsJson["options"]["idle mode"]["index"]
			},
			"camera mode": {
				"value": settingsJson["options"]["camera mode"]["list"],
				"description": "camera type",
				"ID": settingsJson["options"]["camera mode"]["index"]
			},
			"pause music": {
				"value": settingsJson["options"]["pause music"]["list"],
				"description": "pause music",
				"ID": settingsJson["options"]["pause music"]["index"]
			}
		}
	};

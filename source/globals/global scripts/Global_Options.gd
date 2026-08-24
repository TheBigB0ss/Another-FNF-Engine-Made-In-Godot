extends Node

var updated_options = [];

var optionList = {};
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
var health_bar_alpha = 1.0;
var full_screen = false;
var volume = 1;
var isUsingBot = false;
var playMissSound = true;
var playNoteHitSound = false;
var showMsText = false;

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

var sickWindow = 45.0;
var goodWindow = 90.0;
var badWindow = 130.0;

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
	"chartKey": [KEY_7, "7", 3],
	"offsetKey": [KEY_8, "8", 3],
	"camEditorKey": [KEY_9, "9", 3],
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
			
	var defaultList = get_option_list();
	
	for i in defaultList:
		if !optionList.has(i):
			optionList[i] = i;
			continue;
			
		for option in defaultList[i]:
			if !optionList[i].has(option):
				optionList[i][option] = defaultList[i][option];
			else:
				if typeof(optionList[i][option]) == TYPE_DICTIONARY:
					if (optionList[i][option].has("list")):
						if optionList[i][option]["list"] != defaultList[i][option]["list"]:
							optionList[i][option]["list"] = defaultList[i][option]["list"]
							
						if optionList[i][option].has("index"):
							optionList[i][option]["index"] = clamp(optionList[i][option]["index"], 0, defaultList[i][option]["list"].size() - 1);
							
	for i in optionList.keys():
		if !defaultList.has(i):
			optionList.erase(i);
			
	save_settings();
	apply_changes();
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if GlobalOptions.full_screen else DisplayServer.WINDOW_MODE_WINDOWED);
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if GlobalOptions.vsync else DisplayServer.VSYNC_DISABLED);
	
func update_vsync(toggle): DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggle else DisplayServer.VSYNC_DISABLED);
func update_windowMode(toggle): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggle else DisplayServer.WINDOW_MODE_WINDOWED);

func save_settings():
	var new_jsonFile = FileAccess.open("user://Settings.json", FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(optionList));
	new_jsonFile.close();
	apply_changes();
	
func load_settings():
	if FileAccess.file_exists("user://Settings.json"):
		var new_jsonFile = FileAccess.open("user://Settings.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		optionList = jsonData.get_data();
		new_jsonFile.close();
	else:
		reset_settings();
		
func reset_settings():
	optionList = get_option_list();
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
	
func get_key(key_code) -> int:
	var ev = InputEventKey.new();
	ev.keycode = keys[key_code][0];
	return ev.keycode;

func get_key_input(key_code) -> InputEventKey:
	var ev = InputEventKey.new();
	ev.keycode = keys[key_code][0];
	return ev;

func get_option_value(opt_name):
	return optionList["options"][opt_name]["list"][optionList["options"][opt_name]["index"]];
	
func get_value(opt_name, category):
	return optionList[category][opt_name];
	
func set_setting(setting, category, value):
	optionList[category][setting] = value;
	apply_changes();
	save_settings();
	
func save_opts_dic(opt, value):
	optionList["options"][opt]["index"] = value;
	apply_changes();
	save_settings();
	
func rebind_keys(key_selected, new_key, key_value):
	optionList["keys"][key_selected][0] = key_value;
	optionList["keys"][key_selected][1] = new_key;
	
	save_settings();
	
func change_array_opt(opt_name, change, category):
	optionList["options"][opt_name]["index"] += change;
	optionList["options"][opt_name]["index"] = wrapi(optionList["options"][opt_name]["index"], 0, len(optionList["options"][opt_name]["list"]));
	
	var newId = optionList["options"][opt_name]["index"];
	var new_value = optionList["options"][opt_name]["list"][newId];
	
	set_setting(opt_name, category, new_value);
	save_opts_dic(opt_name, optionList["options"][opt_name]["index"]);
	
func change_bool_opt(opt_name, category):
	var value = optionList[category][opt_name];
	value = !value;
	
	set_setting(opt_name, category, value);
	
	match opt_name:
		"fullscreen":
			update_windowMode(value);
		"vsync":
			update_vsync(value);
			
func change_int_opt(opt_name, category, change, min_value, max_value):
	optionList[category][opt_name] += change;
	optionList[category][opt_name] = clamp(optionList[category][opt_name], min_value, max_value);
	optionList[category][opt_name] = snapped(optionList[category][opt_name], 0.1);
	
	apply_changes();
	save_settings();
	
func set_options():
	return {
		"graphics": {
			"fps": {
				"value": int(optionList["graphics"]["fps"]),
				"min val": 30,
				"max val": 250,
				"description": "change FPS (won't work if the uncap fps is enable)"
			},
			"uncap fps": {
				"value": optionList["graphics"]["uncap fps"],
				"description": "uncap fps?"
			},
			"debug text mode":{
				"value": optionList["options"]["debug text mode"]["list"],
				"description": "select the debug text mode",
				"ID": optionList["options"]["debug text mode"]["index"]
			},
			"vsync": {
				"value": optionList["graphics"]["vsync"],
				"description": "disable vsync?"
			},
			"low quality": {
				"value": optionList["graphics"]["low quality"],
				"description": "disable some elements for better performance"
			},
			"use shader": {
				"value": optionList["graphics"]["use shader"],
				"description": "disable shaders?"
			},
			"fullscreen": {
				"value": optionList["graphics"]["fullscreen"],
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
				"value": keys["chartKey"][1], 
				"description": "change chart key"
			},
			"Offset Menu Short Cut Key:":{
				"value": keys["offsetKey"][1], 
				"description": "change offset menu short cut key"
			},
			"Cam Editor Short Cut Key:":{
				"value": keys["camEditorKey"][1], 
				"description": "change cam editor short cut key"
			},
			"Screenshot Key:":{
				"value": keys["F11"][1],
				"description": "change screenshot key"
			}
		},
		"visual": {
			"hud mode": {
				"value": optionList["options"]["hud mode"]["list"],
				"description": "choice hud mode",
				"ID": optionList["options"]["hud mode"]["index"]
			},
			"rating mode": {
				"value": optionList["options"]["rating mode"]["list"],
				"description": "choose how the rating will behave on the game screen",
				"ID": optionList["options"]["rating mode"]["index"]
			},
			"icon type": {
				"value": optionList["options"]["icon type"]["list"],
				"description": "icon style",
				"ID": optionList["options"]["icon type"]["index"]
			},
			"time bar type":{
				"value": optionList["options"]["time bar type"]["list"],
				"description": "time bar mode",
				"ID": optionList["options"]["time bar type"]["index"]
			},
			"health bar alpha": {
				"value": optionList["visual"]["health bar alpha"],
				"description": "health bar opacity"
			},
			"show splashes":{
				"value": optionList["visual"]["show splashes"],
				"description": "show note splashes"
			},
			"show song card":{
				"value": optionList["visual"]["show song card"],
				"description": "show song name"
			},
			"show rating label":{
				"value": optionList["visual"]["show rating label"],
				"description": "enable rating label"
			},
			"hide hud":{
				"value": optionList["visual"]["hide hud"], 
				"description": "hide your hud"
			},
			"screen zoom":{
				"value": optionList["visual"]["screen zoom"],
				"description": "disable camera zoom"
			}
		},
		"gameplay": {
			"ghost tapping": {
				"value": optionList["gameplay"]["ghost tapping"],
				"description": "disable ghost tapping?"
			},
			"down scroll": {
				"value": optionList["gameplay"]["down scroll"],
				"description": "down scroll mode"
			},
			"middle scroll": {
				"value": optionList["gameplay"]["middle scroll"],
				"description": "middle scroll mode"
			},
			"r to restart": {
				"value": optionList["gameplay"]["r to restart"],
				"description": "press R for an instant and painless death"
			},
			"play miss sound": {
				"value": optionList["gameplay"]["play miss sound"],
				"description": "play a sound cue when you missed a note"
			},
			"play note hit sound": {
				"value": optionList["gameplay"]["play note hit sound"],
				"description": "play a sound cue when you press a note"
			},
			"idle mode": {
				"value": optionList["options"]["idle mode"]["list"],
				"description": "select how you want the character to return to idle",
				"ID": optionList["options"]["idle mode"]["index"]
			},
			"camera mode": {
				"value": optionList["options"]["camera mode"]["list"],
				"description": "camera type",
				"ID": optionList["options"]["camera mode"]["index"]
			},
			"pause music": {
				"value": optionList["options"]["pause music"]["list"],
				"description": "pause music",
				"ID": optionList["options"]["pause music"]["index"]
			},
			"show ms text": {
				"value": optionList["gameplay"]["show ms text"],
				"description": "show the ms when you hit a note"
			},
			"sick window": {
				"value": optionList["gameplay"]["sick window"],
				"min val": 15.0,
				"max val": 45.0,
				"description": "change the amount of time to hit a sick (in milliseconds)"
			},
			"good window": {
				"value": optionList["gameplay"]["good window"],
				"min val": 15.0,
				"max val": 90.0,
				"description": "change the amount of time to hit a good (in milliseconds)"
			},
			"bad window": {
				"value": optionList["gameplay"]["bad window"],
				"min val": 15.0,
				"max val": 130.0,
				"description": "change the amount of time to hit a bad (in milliseconds)"
			}
		}
	};
	
func apply_changes():
	down_scroll = optionList["gameplay"]["down scroll"];
	middle_scroll = optionList["gameplay"]["middle scroll"];
	ghost_tapping = optionList["gameplay"]["ghost tapping"];
	restart_action = optionList["gameplay"]["r to restart"];
	playMissSound = optionList["gameplay"]["play miss sound"];
	idleMode = optionList["gameplay"]["idle mode"];
	playNoteHitSound = optionList["gameplay"]["play note hit sound"];
	showMsText = optionList["gameplay"]["show ms text"];
	
	sickWindow = optionList["gameplay"]["sick window"];
	goodWindow = optionList["gameplay"]["good window"];
	badWindow = optionList["gameplay"]["bad window"];
	
	vsync = optionList["graphics"]["vsync"];
	low_quality = optionList["graphics"]["low quality"];
	fps = int(optionList["graphics"]["fps"]);
	uncap_fps = optionList["graphics"]["uncap fps"];
	full_screen = optionList["graphics"]["fullscreen"];
	use_shader = optionList["graphics"]["use shader"];
	debugTextMode = optionList["graphics"]["debug text mode"];
	
	hide_hud = optionList["visual"]["hide hud"];
	timeBar_mode = optionList["visual"]["time bar type"];
	health_bar_alpha = optionList["visual"]["health bar alpha"];
	show_splashes = optionList["visual"]["show splashes"];
	show_songCard = optionList["visual"]["show song card"];
	screen_zoom = optionList["visual"]["screen zoom"];
	show_ratingLabel = optionList["visual"]["show rating label"];
	
	updated_hud = optionList["visual"]["hud mode"];
	rating_mode = optionList["visual"]["rating mode"];
	updated_icon = optionList["visual"]["icon type"];
	
	updated_pause_music = optionList["gameplay"]["pause music"];
	updated_cam = optionList["gameplay"]["camera mode"];
	
	volume = optionList["meta"]["volume"];
	
	ratings_positions["rating"] = optionList["meta"]["rating_pos"];
	ratings_positions["combo"] = optionList["meta"]["combo_pos"];
	ratings_positions["nums"] = optionList["meta"]["nums_pos"];
	
	keys = optionList["keys"];
	
	Engine.max_fps = fps if !uncap_fps else 0;
	
	update_keys();
	
func get_option_list():
	return {
		"meta":{
			"rating_pos": [635, 235, true],
			"combo_pos": [695, 285, true],
			"nums_pos": [464, 293, true],
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
			"idle mode": "step",
			"play note hit sound": false,
			"show ms text": false,
			"sick window": 45.0,
			"good window": 90.0,
			"bad window": 130.0
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
			"chartKey": [KEY_7, "7", 3],
			"offsetKey": [KEY_8, "8", 3],
			"camEditorKey": [KEY_9, "9", 3],
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

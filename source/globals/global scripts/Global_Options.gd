extends Node

var updated_options = [];

var settingsJson = {};
var pause_options = false;
var down_scroll = false;
var middle_scroll = false;
var no_R = false;
var hide_hud = false;
var fps = 60;
var vsync = true;
var ghost_tapping = true;
var low_quality = false;
var time_bar_alpha = 1.0;
var health_bar_alpha = 1.0;
var show_fps = true;
var full_screen = false;
var volume = 1;
var isUsingBot = false;

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

var array_opts = {
	"pause music": {
		"options": ["pause song", "breakfast"],
		"value": 0
	},
	"hud mode": {
		"options": ["new hud", "classic hud"],
		"value": 0
	},
	"camera mode": {
		"options": ["normal", "smooth"],
		"value": 0
	},
	"icon type": {
		"options": ["default", "new bouncy", "golden apple", "disabled"],
		"value": 0
	},
	"rating mode":{
		"options": ["hud element", "game element"],
		"value": 0
	}
};

var updated_pause_music = "pause song";
var updated_hud = "new hud";
var updated_cam = "normal";
var updated_icon = "default";
var rating_mode = "hud element";

signal ghost_tapping_miss(note);

func _ready():
	#reset_settings();
	load_settings();
	
	for i in range(0, 1):
		for j in keys.keys():
			keys_list.append(j);
			
	if !settingsJson.has("version") or settingsJson["version"] != 1:
		reset_settings();
		
	apply_changes();
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if GlobalOptions.full_screen else DisplayServer.WINDOW_MODE_WINDOWED);
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if GlobalOptions.vsync else DisplayServer.VSYNC_DISABLED);
	
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
		
func get_setting(setting, value):
	settingsJson[setting] = value;
	save_settings();
	
func save_opts_dic(opt, value):
	settingsJson["array opts"][opt]["value"] = value;
	save_settings();
	
func rebind_keys(key_selected, new_key, key_value):
	settingsJson["keys"][key_selected][0] = key_value;
	settingsJson["keys"][key_selected][1] = new_key;
	
	save_settings();
	
func reset_settings():
	settingsJson = {
		"version": 1,
		"pause music": "pause song",
		"hud mode": "new hud",
		"camera mode": "normal",
		"icon type": "default",
		"down scroll": false,
		"rating mode": "hud element",
		"middle scroll": false,
		"no R": false,
		"hide hud": false,
		"vsync": true,
		"ghost tapping": true,
		"low quality": false,
		"time bar alpha": 1.0,
		"health bar alpha": 1.0,
		"fps": 60,
		"screen zoom": true,
		"use shader": true,
		"show splashes": true,
		"show song card": true,
		"full screen": false,
		"show FPS": true,
		"show rating label": false,
		"rating_pos": [635, 235],
		"combo_pos": [695, 285],
		"nums_pos": [464, 293],
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
		"array opts":{
			"pause music": {
				"options": ["pause song", "breakfast"],
				"value": 0
			},
			"hud mode": {
				"options": ["new hud", "classic hud"],
				"value": 0
			},
			"camera mode": {
				"options": ["normal", "smooth"],
				"value": 0
			},
			"icon type": {
				"options": ["default", "disabled"],
				"value": 0
			},
			"rating mode":{
				"options": ["hud element", "game element"],
				"value": 0
			}
		},
		"volume": 1
	};
	save_settings();
	
func apply_changes():
	down_scroll = settingsJson["down scroll"];
	middle_scroll = settingsJson["middle scroll"];
	no_R = settingsJson["no R"];
	hide_hud = settingsJson["hide hud"];
	vsync = settingsJson["vsync"];
	ghost_tapping = settingsJson["ghost tapping"];
	low_quality = settingsJson["low quality"];
	time_bar_alpha = settingsJson["time bar alpha"];
	health_bar_alpha = settingsJson["health bar alpha"];
	keys = settingsJson["keys"];
	array_opts = settingsJson["array opts"];
	fps = int(settingsJson["fps"]);
	
	updated_hud = settingsJson["hud mode"];
	updated_pause_music = settingsJson["pause music"];
	updated_cam = settingsJson["camera mode"];
	updated_icon = settingsJson["icon type"];
	rating_mode = settingsJson["rating mode"];
	
	show_fps = settingsJson["show FPS"];
	full_screen = settingsJson["full screen"];
	use_shader = settingsJson["use shader"];
	show_splashes = settingsJson["show splashes"];
	show_songCard = settingsJson["show song card"];
	screen_zoom = settingsJson["screen zoom"];
	show_ratingLabel = settingsJson["show rating label"];
	volume = settingsJson["volume"];
	
	ratings_positions["rating"] = settingsJson["rating_pos"];
	ratings_positions["combo"] = settingsJson["combo_pos"];
	ratings_positions["nums"] = settingsJson["nums_pos"];
	
	update_keys();
	
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
	
func add_new_option(your_variable, new_option, value):
	load_settings();
	
	settingsJson[new_option] = value;
	your_variable = settingsJson[new_option];
	
	save_settings();
	
func set_options():
	return {
		"graphics": {
			"fps":{
				"value": int(fps), 
				"description": "change FPS LIMIT"
			},
			"vsync":{
				"value": vsync, 
				"description": "enable vsync"
			},
			"low quality":{
				"value": low_quality, 
				"description": "this helps... I think..."
			},
			"use shader":{
				"value": use_shader, 
				"description": "disable shaders?"
			},
			"full screen":{
				"value": full_screen,
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
			"rating mode":{
				"value": array_opts["rating mode"]["options"], 
				"description": "choose how the rating will behave on the game screen", 
				"array value": [array_opts["rating mode"]["value"], "rating mode"]
			},
			"hud mode":{
				"value": array_opts["hud mode"]["options"], 
				"description": "choice hud mode", 
				"array value": [array_opts["hud mode"]["value"], "hud mode"]
			},
			"icon type":{
				"value": array_opts["icon type"]["options"], 
				"description": "choice your icon bouncy", 
				"array value": [array_opts["icon type"]["value"], "icon type"]
			},
			"health bar alpha":{
				"value": health_bar_alpha,
				"description": "your health bar opacity"
			},
			"time bar alpha":{
				"value": time_bar_alpha, 
				"description": "your time bar opacity"
			},
			"show FPS":{
				"value": show_fps, 
				"description": "show fps count"
			},
			"show splashes":{
				"value": show_splashes,
				"description": "show note splashes"
			},
			"show song card":{
				"value": show_songCard, 
				"description": "show song name"
			},
			"show rating label":{
				"value": show_ratingLabel, 
				"description": "enable rating label"
			},
			"hide hud":{
				"value": hide_hud, 
				"description": "hide your hud"
			},
			"screen zoom":{
				"value": screen_zoom, 
				"description": "disable camera zoom"
			}
		},
		"gameplay": {
			"ghost tapping":{
				"value": ghost_tapping,
				"description": "disable ghost tapping?"
			},
			"down scroll":{
				"value": down_scroll,
				"description": "down scroll mode"
			},
			"middle scroll":{
				"value": middle_scroll,
				"description": "middle scroll mode"
			},
			"camera mode": {
				"value": array_opts["camera mode"]["options"], 
				"description": "section camera type", 
				"array value": [array_opts["camera mode"]["value"], "camera mode"]
			},
			"pause music":{
				"value": array_opts["pause music"]["options"],
				"description": "choice the pause song", 
				"array value": [array_opts["pause music"]["value"], "pause music"]
			}
		}
	};

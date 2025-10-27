extends Node

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

var use_shader = true;
var show_splashes = true;
var show_songCard = true;
var screen_zoom = true;
var show_ratingLabel = false;

var keys_list = [];
var keys = {
	"left": [KEY_LEFT, "left"],
	"down": [KEY_DOWN, "down"],
	"up": [KEY_UP, "up"],
	"right": [KEY_RIGHT, "right"],
	"ui_left": [KEY_LEFT, "left"],
	"ui_down": [KEY_DOWN, "down"],
	"ui_up": [KEY_UP, "up"],
	"ui_right": [KEY_RIGHT, "right"],
	"enter": [KEY_ENTER, "enter"],
	"escape": [KEY_ESCAPE, "escape"],
	"equal": [KEY_EQUAL, "equal"],
	"minus": [KEY_MINUS, "minus"],
	"7": [KEY_7, "7"],
	"F11": [KEY_F11, "F11"]
};

var ratings_positions = {
	"rating": [],
	"combo": [],
	"nums": []
};

var array_opts = {
	"pause music": {
		"options": ["pause V1", "pause V2"],
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
	}
};

var updated_pause_music = "pause V1";
var updated_hud = "new hud";
var updated_cam = "normal";
var updated_icon = "default";

signal ghost_tapping_miss;

func _ready():
	#reset_settings();
	load_settings();
	
	for i in range(0, 1):
		for j in keys.keys():
			keys_list.append(j);
			
	if !settingsJson.has("version") or settingsJson["version"] < 8:
		reset_settings();
		
	apply_changes();
	
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
		"version": 8,
		"pause music": "pause V1",
		"hud mode": "new hud",
		"camera mode": "normal",
		"icon type": "default",
		"down scroll": false,
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
			"left": [KEY_LEFT, "left"],
			"down": [KEY_DOWN, "down"],
			"up": [KEY_UP, "up"],
			"right": [KEY_RIGHT, "right"],
			"ui_left": [KEY_LEFT, "left"],
			"ui_down": [KEY_DOWN, "down"],
			"ui_up": [KEY_UP, "up"],
			"ui_right": [KEY_RIGHT, "right"],
			"enter": [KEY_ENTER, "enter"],
			"escape": [KEY_ESCAPE, "escape"],
			"equal": [KEY_EQUAL, "equal"],
			"minus": [KEY_MINUS, "minus"],
			"7": [KEY_7, "7"],
			"F11": [KEY_F11, "F11"]
		},
		"array opts":{
			"pause music": {
				"options": ["pause V1", "pause V2"],
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
	
	show_fps = settingsJson["show FPS"];
	full_screen = settingsJson["full screen"];
	use_shader = settingsJson["use shader"];
	show_splashes = settingsJson["show splashes"];
	show_songCard = settingsJson["show song card"];
	screen_zoom = settingsJson["screen zoom"];
	show_ratingLabel = settingsJson["show rating label"];
	Global.volume = settingsJson["volume"];
	
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
		
func add_new_option(your_variable, new_option, value):
	load_settings();
	
	settingsJson[new_option] = value;
	your_variable = settingsJson[new_option];
	
	save_settings();

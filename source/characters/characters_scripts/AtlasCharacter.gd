@tool
class_name AtlasCharacter extends AtlasSprite

var charData = {};
var charPath = '';
var animList = [];
var posesList = [];

enum CHARACTER_STATES{
	IDLE = 1,
	SINGING = 2,
	HOLDING = 3,
	SPECIAL = 4
};

enum CHARACTER_ANIM_TYPE{
	FREEZE = 1,
	REPEAT = 2,
	NONE = 3
};

var curCharacter = "";

var curIcon = '';
var animatedIcon = false;
var cam_follow_pos = false;
var curAnim = "";
var special_anim = false;

var anim_offset = [];
var camera_pos = [];

var idleTimer = 0;

var characterState = CHARACTER_STATES.IDLE;

var base_position = Vector2.ZERO;

var have_death_animation = false:
	set(value):
		have_death_animation = value;
		notify_property_list_changed();
var death_scene = "";

var anim_type:CHARACTER_ANIM_TYPE = CHARACTER_ANIM_TYPE.FREEZE:
	set(val):
		anim_type = val;
		notify_property_list_changed();
var frame_count = 2.4;

@export_group("character settings", "")

@export_file_path("*.json") var json_path = "";

@export var healthBar_Color = Color();
@export var is_player = false;

@export var anims_timer = {};

var anim_time = 5;
var anim_beat = 2;

func _init() -> void:
	if Engine.is_editor_hint():
		return;
		
	Conductor.new_beat.connect(beat_hit);
	Conductor.new_step.connect(step_hit);
	
func step_hit(_step) -> void:
	pass
	
func beat_hit(_beat) -> void:
	beat_dance(_beat);
	
func init_json(char_json_path):
	var jsonFile = FileAccess.open(char_json_path, FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	charData = jsonData.get_data();
	jsonFile.close();
	
func _ready():
	reload();
	notify_property_list_changed();
	curCharacter = json_path.get_file();
	curCharacter = curCharacter.replace(".json", "");
	
	init_json(json_path);
	
	healthBar_Color = Color(charData.get("HealthBarColor", healthBar_Color));
	
	self.scale = Vector2(charData["scale"][0], charData["scale"][1]);
	
	is_player = charData.get("isPlayer", is_player);
	cam_follow_pos = charData.get("camera follow pos", cam_follow_pos);
	curIcon = charData.get("HealthIcon", "no_icon");
	camera_pos = charData.get("cameraPos", [0,0]);
	
	for i in charData["Poses"].size():
		animList.append(charData["Poses"][i]["Anim"]);
		posesList.append(charData["Poses"][i]["Prefix"]);
		
	anims_timer = {};
	for i in animList.size():
		anims_timer[animList[i]] = [
			int(charData["Poses"][i].get("anim beat", 2)),
			int(charData["Poses"][i].get("Anim Time", 5)),
			charData["Poses"][i].get("special anim", false)
		];
		
	dance();
	
func _process(delta):
	super(delta);
	if !Engine.is_editor_hint():
		character_process(delta);
		
func character_process(delta):
	if (curAnim.begins_with("sing") or curAnim.contains("sing") or special_anim) && characterState != CHARACTER_STATES.HOLDING:
		characterState = CHARACTER_STATES.IDLE;
		idleTimer += delta;
		
	if SongData.is_not_in_cutscene && !Global.is_on_video:
		if idleTimer >= Conductor.stepCrochet * anim_time * 0.001:
			if curAnim.contains("sing") or special_anim:
				dance();
				frame = newFrame;
				idleTimer = 0;
				
var can_dance = false;
var have_anims = false;
func dance():
	have_anims = animList.has("danceRight") && animList.has("danceLeft");
	if have_anims:
		can_dance = !can_dance;
		_playAnim("danceRight" if can_dance else "danceLeft");
		
	if animList.has("idle dance"):
		_playAnim("idle dance");
		
var current_anim = "";
var newLimit = 0;
var newFrame = 0;
func _playAnim(anim="", note:Note = null):
	playing = true;
	var longNote = note.isSustain if is_instance_valid(note) else false;
	for i in animList.size():
		if animList[i] != anim:
			continue;
			
		for j in animationData["AN"]["TL"]["L"]:
			for k in j["FR"]:
				if k.get("N", "") == posesList[i]:
					newFrame = k["I"];
					newLimit = (k["I"] + k["DU"])-1;
					
		anim_beat = anims_timer[anim][0];
		anim_time = anims_timer[anim][1];
		special_anim = anims_timer[anim][2];
		
		var prevState = characterState;
		
		if animList[i].contains("sing"):
			characterState = (CHARACTER_STATES.IDLE if note.sustainLength <= 0 or note.missedLongNote else CHARACTER_STATES.HOLDING) if longNote else CHARACTER_STATES.SINGING;
			
		elif special_anim:
			characterState = CHARACTER_STATES.SPECIAL;
			
		elif curAnim == "idle dance":
			characterState = CHARACTER_STATES.IDLE;
			frame = newFrame;
			
		if characterState != CHARACTER_STATES.IDLE:
			match characterState:
				CHARACTER_STATES.HOLDING:
					if prevState != CHARACTER_STATES.HOLDING or (current_anim != posesList[i] && curAnim != "idle dance" && curAnim != "hit"):
						frame = newFrame;
					if prevState != CHARACTER_STATES.HOLDING:
						frame = newFrame;
						
				CHARACTER_STATES.SINGING:
					frame = newFrame;
					
		if animList[i].begins_with("sing") or charData["Poses"][i].has("Anim Time"):
			idleTimer = 0;
			
		loop_anim();
		
		if current_anim == posesList[i] && animList[i].begins_with("sing") && characterState != CHARACTER_STATES.SINGING:
			return;
			
		current_anim = posesList[i];
		limit = newLimit;
		
		break;
		
	curAnim = anim;
	
func loop_anim():
	if characterState != CHARACTER_STATES.HOLDING:
		return;
		
	match anim_type:
		1:
			frame = newFrame;
		2:
			if frame > (newFrame + frame_count):
				frame = newFrame;
				
func _get_property_list():
	var properties: Array[Dictionary] = [];
	
	properties.append({
		"name": "anim_type",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "FREEZE:1,REPEAT:2,NONE:3",
		"usage": PROPERTY_USAGE_DEFAULT
	});
	
	properties.append({
		"name": "have_death_animation",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	});
	
	if anim_type == CHARACTER_ANIM_TYPE.REPEAT:
		properties.append({
			"name": "frame_count",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_DEFAULT
		});
		
	if have_death_animation:
		properties.append({
			"name": "death_scene",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tscn",
			"usage": PROPERTY_USAGE_DEFAULT
		});
		
	return properties;
	
func beat_dance(beat):
	if (beat % int(anim_beat) == 0) && !curAnim.begins_with("sing") && !special_anim:
		dance();

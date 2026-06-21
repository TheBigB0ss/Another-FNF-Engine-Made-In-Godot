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

enum IDLE_MODE{
	DEFAULT = 1,
	BEAT = 2,
	STEP = 3
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
		
var anim_type:CHARACTER_ANIM_TYPE = CHARACTER_ANIM_TYPE.FREEZE:
	set(val):
		anim_type = val;
		notify_property_list_changed();
		
var idle_type:IDLE_MODE = IDLE_MODE.DEFAULT:
	set(val):
		idle_type = val;
		notify_property_list_changed();
		
var death_scene = "";
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
	
func beat_hit(beat) -> void:
	if idle_type != IDLE_MODE.BEAT:
		return;
		
	back_to_idle(beat);
	
func step_hit(step) -> void:
	if idle_type != IDLE_MODE.STEP:
		return;
		
	back_to_idle(step);
	
func init_json(char_json_path):
	var jsonFile = FileAccess.open(char_json_path, FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	charData = jsonData.get_data();
	jsonFile.close();
	
func init_character(parent, char_position, char_zIndex, char_path, child_id):
	if char_path == "none":
		return;
		
	var new_char = load("res://source/characters/characters_scenes/" + char_path + ".tscn").instantiate();
	new_char.position = char_position;
	new_char.z_index = char_zIndex;
	parent.add_child(new_char);
	parent.move_child(new_char, child_id);
	
	return new_char;
	
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
	anim_type = charData.get("anim type", anim_type);
	
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
		
	if idle_type == IDLE_MODE.DEFAULT && !Engine.is_editor_hint():
		match GlobalOptions.idleMode:
			"beat":
				idle_type = IDLE_MODE.BEAT;
			"step":
				idle_type = IDLE_MODE.STEP;
				
	dance();
	
func _process(delta):
	super(delta);
	if !Engine.is_editor_hint():
		character_process(delta);
		
var prevState = null;
var curNote:Note = null;
var animNote:Note = null;
var sing_timer = 0;
func update_character_state(delta):
	prevState = characterState
	
	if !curAnim.contains("sing"):
		return;
		
	if !is_instance_valid(curNote):
		characterState = CHARACTER_STATES.IDLE;
		return;
		
	if curNote.isSustain:
		characterState = CHARACTER_STATES.HOLDING if (curNote.is_pressing && curNote.sustainLength > 0) else CHARACTER_STATES.IDLE;
		
		if is_instance_valid(animNote) && animNote.curNoteAnim != curNote.curNoteAnim && !animNote.isSustain:
			sing_timer = 0.075;
			characterState = CHARACTER_STATES.SINGING;
			_playAnim(animNote.curNoteAnim);
			
		if sing_timer > 0:
			sing_timer -= delta;
			sing_timer = max(sing_timer, 0.0);
			return;
			
		if characterState == CHARACTER_STATES.HOLDING && curAnim != curNote.curNoteAnim:
			_playAnim(curNote.curNoteAnim);
			
func character_process(delta):
	if Engine.is_editor_hint():
		return;
		
	loop_anim();
	
	update_character_state(delta);
	
	if (curAnim.begins_with("sing") or curAnim.contains("sing") or special_anim) && characterState != CHARACTER_STATES.HOLDING:
		idleTimer += delta;
		
	if SongData.is_not_in_cutscene && !Global.is_on_video:
		if idleTimer >= Conductor.stepCrochet * anim_time * 0.001:
			if curAnim.contains("sing") or special_anim:
				dance();
				idleTimer = 0;
				
var can_dance = false;
var have_anims = false;
func dance():
	have_anims = animList.has("danceRight") && animList.has("danceLeft");
	if have_anims:
		can_dance = !can_dance;
		_playAnim("danceRight" if can_dance else "danceLeft");
		characterState = CHARACTER_STATES.IDLE;
		
	if animList.has("idle dance"):
		_playAnim("idle dance");
		
var current_anim = "";
var newLimit = 0;
var newFrame = 0;
func _playAnim(anim = "", special = false):
	playing = true;
	for i in animList.size():
		#if is_instance_valid(curNote) && characterState == CHARACTER_STATES.HOLDING && anim.begins_with("sing") && curNote.curNoteAnim != anim:
		#	anim = curNote.curNoteAnim;
			
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
		
		if special_anim or special:
			characterState = CHARACTER_STATES.SPECIAL;
		if curAnim == "idle dance":
			characterState = CHARACTER_STATES.IDLE;
			frame = newFrame;
		if animList[i].begins_with("sing") && is_instance_valid(curNote):
			characterState = CHARACTER_STATES.SINGING;
			
		if characterState != CHARACTER_STATES.IDLE:
			match characterState:
				CHARACTER_STATES.HOLDING:
					sing_timer = 0;
					if prevState == CHARACTER_STATES.HOLDING:
						frame = newFrame;
						
					frame = newFrame;
					
				CHARACTER_STATES.SINGING, CHARACTER_STATES.SPECIAL:
					frame = newFrame;
					
		if animList[i].begins_with("sing") or charData["Poses"][i].has("Anim Time") or characterState == CHARACTER_STATES.SPECIAL:
			idleTimer = 0;
			
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
	
	properties.append({
		"name": "idle_type",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "DEFAULT:1,BEAT:2,STEP:3",
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
	
func back_to_idle(idle_timer):
	if (idle_timer % int(anim_beat) == 0) && !curAnim.begins_with("sing") && !special_anim:
		dance();

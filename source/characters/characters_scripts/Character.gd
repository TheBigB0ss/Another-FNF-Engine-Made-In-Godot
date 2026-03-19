@tool
extends CharacterData

enum CHARACTER_STATES {
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

@onready var character = $character;

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

func _ready():
	notify_property_list_changed();
	curCharacter = json_path.get_file();
	curCharacter = curCharacter.replace(".json", "");
	
	init_json(json_path);
	
	healthBar_Color = Color(charData.get("HealthBarColor", healthBar_Color));
	
	character.scale = Vector2(charData["scale"][0], charData["scale"][1]);
	character.flip_h = charData["FlipX"];
	character.flip_v = charData["FlipY"];
	
	is_player = charData.get("isPlayer", is_player);
	cam_follow_pos = charData.get("camera follow pos", cam_follow_pos);
	camera_pos = charData.get("cameraPos", [0,0]);
	curIcon = charData.get("HealthIcon", "no_icon");
	
	for i in charData["Poses"].size():
		animList.append(charData["Poses"][i]["Anim"]);
		posesList.append(charData["Poses"][i]["Name"]);
		
	anims_timer = {}
	for i in animList.size():
		anims_timer[animList[i]] = [
			int(charData["Poses"][i].get("anim beat", 2)),
			int(charData["Poses"][i].get("Anim Time", 5)),
			charData["Poses"][i].get("special anim", false)
		];
		
	base_position = self.position;
	
	dance();
	
func _process(delta):
	if Engine.is_editor_hint():
		return;
		
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
		
	if animList.has("idle dance"):
		character.speed_scale = 1.0;
		_playAnim("idle dance");
		
	if curCharacter == "picoSpeaker":
		_playAnim("shoot%s"%[int(randf_range(1, 4))]);
		
func _playAnim(anim="", note:Note = null):
	var longNote = note.isSustain && note.isSustain if is_instance_valid(note) else false;
	for i in animList.size():
		if animList[i] != anim:
			continue;
			
		anim_beat = anims_timer[anim][0];
		anim_time = anims_timer[anim][1];
		special_anim = anims_timer[anim][2];
		
		character.offset.x = charData["Poses"][i]["Offset"][0];
		character.offset.y = charData["Poses"][i]["Offset"][1];
		
		var prevState = characterState;
		
		if animList[i].contains("sing"):
			characterState = (CHARACTER_STATES.IDLE if note.sustainLenght <= 0 or note.MissedlongNote else CHARACTER_STATES.HOLDING) if longNote else CHARACTER_STATES.SINGING;
		elif special_anim:
			characterState = CHARACTER_STATES.SPECIAL;
		elif curAnim == "idle dance":
			characterState = CHARACTER_STATES.IDLE;
			
		if characterState != CHARACTER_STATES.IDLE:
			match characterState:
				CHARACTER_STATES.HOLDING:
					if prevState != CHARACTER_STATES.HOLDING or (character.animation != posesList[i] && curAnim != "idle dance" && curAnim != "hit"):
						character.frame = 0;
					if prevState != CHARACTER_STATES.HOLDING:
						character.frame = 0;
						
				CHARACTER_STATES.SINGING:
					character.frame = 0;
					
		if animList[i].begins_with("sing") or charData["Poses"][i].has("Anim Time"):
			idleTimer = 0;
			
		loop_anim();
		
		if character.animation == posesList[i] && animList[i].begins_with("sing") && characterState != CHARACTER_STATES.SINGING:
			return;
			
		character.play(posesList[i]);
		
	curAnim = anim;
	
func loop_anim():
	if characterState != CHARACTER_STATES.HOLDING:
		return;
		
	match anim_type:
		1:
			character.frame = 0;
		2:
			if (character.frame + character.frame_progress) > frame_count:
				character.frame = 0;
				character.frame_progress = 0;
				
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
	
func beat_hit(beat) -> void:
	beat_dance(beat);
	
func beat_dance(beat):
	if (beat % int(anim_beat) == 0) && !curAnim.begins_with("sing") && !special_anim:
		dance();

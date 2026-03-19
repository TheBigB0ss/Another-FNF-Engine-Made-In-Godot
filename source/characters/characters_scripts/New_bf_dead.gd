extends CharacterData

@export_group("death screen settings", "")
@export_file_path("*.json") var json_path = "";

@onready var character = $'Character_Sprite';
@onready var character_anim = $'Character_Animation';

var curAnim = "";
var curIcon = "";

var camera_pos = [];
var anim_offset = [];

var idleTimer = 0;
var confirmTimer = 0;

var anim_time = 0;
var cam_follow_pos = false;

var base_position = Vector2.ZERO;

func _ready():
	charPath = json_path.get_file();
	charPath = charPath.replace(".json", "");
	
	init_json(json_path);
	
	character.scale = Vector2(charData["scale"][0], charData["scale"][1]);
	character.flip_h = charData["FlipX"];
	character.flip_v = charData["FlipY"];
	curIcon = charData.get("HealthIcon", "no_icon");
	
	for i in charData["Poses"].size():
		animList.append(charData["Poses"][i]["Anim"]);
		posesList.append(charData["Poses"][i]["Name"]);
		
	base_position = character.position;
	
	_playAnim("dead");
	
func _process(delta):
	if curAnim.begins_with("dead") && SongData.isOnDeathScreen:
		idleTimer += delta;
		
	if idleTimer >= 2 && curAnim != "dead confirm" && SongData.isOnDeathScreen:
		bf_loop_anim();
		idleTimer = 0;
		
	if idleTimer == 0 && curAnim == "dead confirm":
		confirmTimer += delta;
		
func _playAnim(anim):
	for i in animList.size():
		if animList[i] == anim:
			var pose_offset = Vector2(charData["Poses"][i]["Offset"][0], charData["Poses"][i]["Offset"][1]);
			
			character.position = base_position + pose_offset;
			character_anim.play(posesList[i]);
			character_anim.seek(0.0);
			
	curAnim = anim;
	
func bf_loop_anim():
	if SongData.isOnDeathScreen:
		_playAnim("dead loop");

extends CharacterData

@export_group("death screen settings", "")
@export_file_path("*.json") var json_path = "";

@onready var character = $'character';


var curAnim = "";
var curIcon = "";

var camera_pos = [];
var anim_offset = [];

var idleTimer = 0;
var confirmTimer = 0;

var anim_time = 0;
var cam_follow_pos = false;

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
			character.offset.x = charData["Poses"][i]["Offset"][0];
			character.offset.y = charData["Poses"][i]["Offset"][1];
			character.play(posesList[i]);
			character.frame = 0;
			
	curAnim = anim;
	
func bf_loop_anim():
	if SongData.isOnDeathScreen:
		_playAnim("dead loop");

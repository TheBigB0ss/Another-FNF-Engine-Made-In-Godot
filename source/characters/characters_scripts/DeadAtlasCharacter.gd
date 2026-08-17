@tool
class_name DeadAtlasCharacter extends AtlasSprite

var charData = {};
var curCharacter = '';
var animList = [];
var posesList = [];

@export_group("death screen settings", "")
@export_file_path("*.json") var json_path = "";

var curAnim = "";
var curIcon = "";

var camera_pos = [];
var anim_offset = [];

var idleTimer = 0;
var confirmTimer = 0;

var anim_time = 0;
var cam_follow_pos = false;

var is_animated_sprite = false;

var anim_type = 1;

var base_position = Vector2.ZERO;

var character = self;

func init_json(char_json_path):
	var jsonFile = FileAccess.open(char_json_path, FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	charData = jsonData.get_data();
	jsonFile.close();
	
func _ready():
	is_animated_sprite = character is AnimatedSprite2D;
	
	curCharacter = json_path.get_file();
	curCharacter = curCharacter.replace(".json", "");
	
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
	super._process(delta);
	
	if Engine.is_editor_hint():
		return;
		
	if curAnim.begins_with("dead") && SongData.isOnDeathScreen:
		idleTimer += delta;
		
	if idleTimer >= 2 && curAnim != "dead confirm" && SongData.isOnDeathScreen:
		bf_loop_anim();
		idleTimer = 0;
		
	if idleTimer == 0 && curAnim == "dead confirm":
		confirmTimer += delta;
		
var newLimit = 0;
var newFrame = 0;
func _playAnim(anim):
	for i in animList.size():
		if animList[i] != anim:
			continue;
			
		for j in animationData["AN"]["TL"]["L"]:
			for k in j["FR"]:
				if k.get("N", "") == posesList[i]:
					start_frame = int(k["I"]);
					timer = float(k["I"]);
					newFrame = k["I"];
					newLimit = (k["I"] + k["DU"])-1;
					
		frame = newFrame;
		limit = newLimit;
		set_offset(i);
		
	curAnim = anim;
	
	
func set_offset(animID):
	var pose_offset = Vector2(charData["Poses"][animID]["Offset"][0], charData["Poses"][animID]["Offset"][1]) if charData["Poses"][animID].has("Offset") else Vector2.ZERO;
	
	if !Engine.is_editor_hint():
		character.position = (base_position + pose_offset);
		
func bf_loop_anim():
	if SongData.isOnDeathScreen:
		_playAnim("dead loop");

extends CharacterData

@export var have_death_animation = false;
@export var death_scene = "";
@export var json_path = "";
@onready var character = $'character';
var curCharacter = "";

var healthBar_Color = Color();
var curIcon = '';
var animatedIcon = false;
var loopAnim = false;
var is_player = false;
var cam_follow_pos = false;
var curAnim = "";

var anim_offset = [];
var camera_pos = [];

var idleTimer = 0;
var anim_time = 5;
var anim_beat = 2;

func _ready():
	charPath = json_path;
	curCharacter = charPath;
	
	var jsonFile = FileAccess.open("res://assets/characters/%s.json"%[charPath],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	charData = jsonData.get_data();
	jsonFile.close();
	
	set_data_vars("camera follow pos", false);
	set_data_vars("AnimatedIcon", false);
	set_data_vars("LoopAnim", false);
	set_data_vars("cameraPos", [1, 1]);
	set_data_vars("scale", [1, 1]);
	set_data_vars("anim time", 5);
	
	character.scale = Vector2(charData["scale"][0], charData["scale"][1]);
	character.flip_h = charData["FlipX"];
	character.flip_v = charData["FlipY"];
	
	camera_pos = [charData["cameraPos"][0], charData["cameraPos"][1]]
	anim_time = charData["anim time"];
	is_player = charData["isPlayer"];
	curIcon = charData["HealthIcon"];
	animatedIcon = charData["AnimatedIcon"];
	healthBar_Color = Color(charData["HealthBarColor"]);
	loopAnim = charData["LoopAnim"];
	cam_follow_pos = charData["camera follow pos"];
	
	for i in charData["Poses"].size():
		animList.append(charData["Poses"][i]["Anim"]);
		posesList.append(charData["Poses"][i]["Name"]);
		
	dance();
	
func set_data_vars(null_var, null_value):
	if !charData.has(null_var):
		charData[null_var] = null_value;
		
func _process(delta):
	if curAnim.begins_with("sing") or curAnim.contains("sing"):
		idleTimer += delta;
		
	if Global.is_not_in_cutscene && !Global.is_on_video:
		if idleTimer >= Conductor.stepCrochet * anim_time * 0.001:
			if curAnim.contains("sing"):
				dance();
				idleTimer = 0;
				
var can_dance = false;
var have_anims = false;
func dance():
	self.modulate = Color.WHITE;
	have_anims = animList.has("danceRight") && animList.has("danceLeft");
	if have_anims:
		can_dance = !can_dance;
		_playAnim("danceRight" if can_dance else "danceLeft");
		
	if animList.has("idle dance"):
		character.speed_scale = 1.0;
		_playAnim("idle dance");
		
	if curCharacter == "picoSpeaker":
		_playAnim("shoot%s"%[int(randf_range(1, 4))]);
		
func _playAnim(anim="", inLoop=false):
	for i in animList.size():
		if animList[i] == anim:
			if !charData["Poses"][i].has("anim beat"):
				anim_beat = 2;
			else:
				anim_beat = charData["Poses"][i]["anim beat"];
				
			character.offset.x = charData["Poses"][i]["Offset"][0];
			character.offset.y = charData["Poses"][i]["Offset"][1];
			
			if curAnim != "idle dance" && !loopAnim && curAnim != "hit":
				character.frame = 0;
				
			character.play(posesList[i]);
			
			if animList[i].begins_with("sing"):
				idleTimer = 0;
				
	if loopAnim:
		loop_anim(inLoop);
		
	curAnim = anim;
	
func loop_anim(inLoop):
	if (character.frame + character.frame_progress) > 2.4:
		character.frame = 0;
		character.frame_progress = 0;
		
	if !inLoop:
		character.frame = 0;

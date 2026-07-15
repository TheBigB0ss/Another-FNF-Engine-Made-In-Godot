@tool
class_name ChartCharacter extends SparrowSprite

var curAnim = "";
var idleTimer = 0.0;

var base_position = Vector2.ZERO;
var charData = {};

var animList = [];
var posesList = [];

var goToIdle = true;

@export var path = "";

func _ready():
	var jsonFile = FileAccess.open("res://assets/images/editors/chart preview/%s.json"%[path], FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	charData = jsonData.get_data();
	jsonFile.close();
	
	for i in charData["Poses"].size():
		animList.append(charData["Poses"][i]["Anim"]);
		posesList.append(charData["Poses"][i]["Name"]);
		
	_playAnim("idle dance");
	
func _process(delta):
	super(delta);
	
	if Engine.is_editor_hint():
		return;
		
	if !goToIdle:
		return;
		
	if curAnim != "idle dance":
		idleTimer += delta;
		
	if idleTimer >= Conductor.stepCrochet * 5 * 0.001:
		if curAnim != "idle dance":
			_playAnim("idle dance");
			idleTimer = 0;
			
func _playAnim(anim=""):
	for i in animList.size():
		if animList[i] != anim:
			continue;
			
		var pose_offset = Vector2(
			charData["Poses"][i]["Offset"][0],
			charData["Poses"][i]["Offset"][1]
		);
		
		offset = pose_offset;
		play(posesList[i]);
		
		if animList[i].begins_with("sing"):
			idleTimer = 0;
			
		break;
		
	curAnim = anim;
	

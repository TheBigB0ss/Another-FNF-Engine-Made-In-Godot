extends Node2D

@onready var chart_enemy_anim = $character;
var curAnim = "";
var idleTimer = 0.0;

var base_position = Vector2.ZERO;
var charData = {};

var animList = [];
var posesList = [];

func _ready():
	var jsonFile = FileAccess.open("res://assets/images/chart characters/enemy/enemy_chart.json",FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	charData = jsonData.get_data();
	jsonFile.close();
	
	for i in charData["Poses"].size():
		animList.append(charData["Poses"][i]["Anim"]);
		posesList.append(charData["Poses"][i]["Name"]);
		
	base_position = self.position;
	_playAnim("idle dance");
	
func play_cool_anim(anim_id):
	match anim_id:
		0, 4:
			_playAnim('singLeft');
		1, 5:
			_playAnim('singDown');
		2, 6:
			_playAnim('singUp');
		3, 7:
			_playAnim('singRight');
			
func _process(delta):
	if curAnim != "idle dance":
		idleTimer += delta;
		
	if idleTimer >= Conductor.stepCrochet * 5 * 0.001:
		if curAnim != "idle dance":
			_playAnim("idle dance");
			idleTimer = 0;
			
func _playAnim(anim=""):
	for i in animList.size():
		if animList[i] == anim:
			var pose_offset = Vector2(
				charData["Poses"][i]["Offset"][0],
				charData["Poses"][i]["Offset"][1]
			);
			
			chart_enemy_anim.offset = pose_offset;
			
			chart_enemy_anim.frame = 0;
			chart_enemy_anim.play(posesList[i]);
			
			if animList[i].begins_with("sing"):
				idleTimer = 0;
				
			if (chart_enemy_anim.frame + chart_enemy_anim.frame_progress) > 2.4:
				chart_enemy_anim.frame = 0;
				chart_enemy_anim.frame_progress = 0;
				
	curAnim = anim;
	

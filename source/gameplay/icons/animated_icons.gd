class_name AnimatedIcon extends AnimatedSprite2D

var icon_frames = "";
var icon_char = "";
var icon_scale = 1.0;
var end_transition = false;

var icon_data = {};
var iconAnimList = [];
var iconPosesList = [];

func _ready() -> void:
	self.sprite_frames = load("res://%s"%[icon_frames]);
	
	print(icon_frames)
	print(icon_char)
	var jsonFile = FileAccess.open("res://assets/images/icons/animated/%s.json"%[icon_char],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	icon_data = jsonData.get_data();
	jsonFile.close();
	
	if icon_data.has("IconPoses"):
		for i in icon_data["IconPoses"].size():
			iconAnimList.append(icon_data["IconPoses"][i]["Anim"]);
			iconPosesList.append(icon_data["IconPoses"][i]["Name"]);
			
	self.animation_finished.connect(finish_icon_anim);
	self.animation_changed.connect(change_icon_anim);
	
var cur_iconAnim = "";
func play_icon_anim(anim):
	for i in iconAnimList.size():
		if iconAnimList[i] == anim:
			self.play(iconPosesList[i]);
			
	cur_iconAnim = anim;
	
func finish_icon_anim():
	if iconAnimList.has("transition"):
		if cur_iconAnim == "transition":
			end_transition = true;
		else:
			end_transition = false;
			
	if !iconAnimList.has("transition"):
		end_transition = true;
		
func change_icon_anim():
	if cur_iconAnim != "transition":
		end_transition = false;
		
	if !iconAnimList.has("transition"):
		end_transition = true;

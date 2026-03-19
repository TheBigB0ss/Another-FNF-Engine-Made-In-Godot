class_name AnimatedIcon extends AnimatedSprite2D

var icon_frames = "";
var icon_char = "";
var icon_scale = 1.0;
var end_transition = false;

var icon_data = {};
var iconAnimList = [];
var iconPosesList = [];

func _ready() -> void:
	Conductor.new_beat.connect(beat_hit);
	
	self.sprite_frames = load("res://%s"%[icon_frames]);
	
	var jsonFile = FileAccess.open("res://assets/images/icons/animated/%s/%s.json"%[icon_char, icon_char], FileAccess.READ);
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
	
func _process(_delta: float) -> void:
	self.scale = lerp(self.scale, Vector2(1.0, 1.0), 0.08);
	
var cur_iconAnim = "";
func play_anim(anim):
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
	else:
		end_transition = true;
		
func change_icon_anim():
	end_transition = false if cur_iconAnim != "transition" else true;
	
func play_icon_anim(anim):
	var cur_anim = anim;
	if anim in ["win", "lose"] && !self.end_transition:
		cur_anim = "transition";
		
	play_anim(cur_anim);
	
func beat_hit(_beat):
	if GlobalOptions.updated_icon == "disabled":
		return;
		
	self.scale = Vector2(1.25, 1.25);

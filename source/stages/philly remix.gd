extends Node2D

@onready var darnell = $'characters/Darnell';
@onready var nene = $'characters/Nene';
@onready var darnellAss = $characters/DarnellAss;

@onready var darnellStrum = $strums/DarnellStrum;
@onready var neneStrum = $strums/NeneStrum;
@onready var strums = $strums;

var colorArray = [];
var song = "";
var songDiff = "";
var buddys_data = {};
var buddys_array = [];

var itsBuddysPart = false;
var buddyTarget = null;

var colors = {
	"red": Color("#FD4531"),
	"blue": Color("#31A2FD"),
	"green": Color("#31FD8C"),
	"orange": Color("#FBA633"),
	"pink": Color("#FB33F5")
};

func _ready():
	Global.connect("new_step", step_hit);
	Global.connect("new_beat", beat_hit);
	
	if Global.is_playing:
		song = Global.songsShit[0].to_lower() if Global.isStoryMode else Global.songsShit.to_lower();
		songDiff = Global.diffsShit;
		
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
	if song != "blammed" && songDiff == "remix":
		darnell.hide();
		nene.hide();
		
	if Global.is_playing:
		if song == "philly-nice" && songDiff == "remix":
			var jsonFile = FileAccess.open("res://assets/data/philly-nice/DarnellSpeaker.json", FileAccess.READ);
			var jsonData = JSON.new();
			jsonData.parse(jsonFile.get_as_text());
			buddys_data = jsonData.get_data();
			jsonFile.close();
			
			for i in buddys_data["song"]["notes"]:
				for j in i["sectionNotes"]:
					buddys_array.insert(0, [j[0], j[1], j[2], false]);
					
			buddys_array.sort_custom(Callable(self, "sort_notes"));
		
	for i in colors.keys():
		colorArray.append(i);
		
	set_color();
	
func _process(delta):
	if itsBuddysPart:
		strums.modulate.a = lerp(strums.modulate.a, 1.0, 0.10);
		var picoStrum = get_tree().current_scene.get("opponentStrum");
		picoStrum.position.x = lerp(picoStrum.position.x, -850.0, 0.05);
		
		get_tree().current_scene.call("cam_follow_poses", darnell);
		get_tree().current_scene.call("cam_follow_poses", nene);
		
	if buddyTarget == null:
		buddyTarget = darnell;
		
	if buddys_array.is_empty() && song != "philly-nice":
		return;
		
	if Conductor.getSongTime > buddys_array[0][0]:
		for i in buddys_array:
			if Conductor.getSongTime >= i[0] && !i[3]:
				buddys_anim(int(i[1]));
				i[3] = true;
				
func sort_notes(a, b): 
	return a[0] < b[0];
	
func set_color():
	$lights.modulate = colors[colorArray.pick_random()];
	$lights.modulate.a = 1;
	
	var tw = get_tree().create_tween();
	tw.tween_property($lights, "modulate:a", 0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
func soakedAppears():
	return randi_range(0, 1000);
	
func everyone_dance(char, beat):
	if (beat % 2 == 0 if char.anim_beat == 2 else beat % int(char.anim_beat) == 0) && !char.curAnim.begins_with("sing") && char.curAnim != "singLaugh":
		char.dance();
		
func beat_hit(beat):
	everyone_dance(nene, beat);
	everyone_dance(darnell, beat);
	
	if beat % 4 == 0:
		set_color();
		
	if song == "philly-nice" && songDiff == "remix":
		match beat:
			260:
				$ColorRect.show();
			268:
				darnellAss.visible = (randf_range(0, 100) <= 2);
				itsBuddysPart = true;
				$ColorRect.hide();
				if !darnellAss.visible:
					darnell.show();
				nene.show();
				funny_guy();
				
	if darnellAss.visible:
		if (beat % 2 == 0):
			darnellAss.frame = 0;
			
func step_hit(step):
	if Global.is_playing:
		var new_cam_target = get_tree().current_scene.get("cam_target");
		var camOnBf = get_tree().current_scene.get("camera_on_Bf");
		
		if itsBuddysPart && song == "philly-nice" && songDiff == "remix":
			if camOnBf:
				new_cam_target = get_tree().current_scene.get("bf");
			else:
				new_cam_target = buddyTarget;
				
			if Global.is_playing:
				get_tree().current_scene.call("move_cam", true if GlobalOptions.updated_cam == "smooth" else false, (new_cam_target.global_position + Vector2(new_cam_target.camera_pos[0], new_cam_target.camera_pos[1])));
				
var animsList = {
	"Darnell": ["singLeft", "singDown", "singUp", "singRight"],
	"Nene": ["singLeft", "singDown", "singUp", "singRight"]
};

func buddys_anim(animData):
	var healthBar = get_tree().current_scene.get("healthBar");
	var icon = get_tree().current_scene.get("iconP2");
	
	if animData < 4:
		if !darnellAss.visible:
			darnell._playAnim(animsList["Darnell"][animData]);
		else:
			darnellAss.frame = 0;
			darnellAss.play("darnell ass_");
			
		play_strum_anim(animData, darnellStrum, 0.45);
		
	elif animData >= 4:
		nene._playAnim(animsList["Nene"][animData-4]);
		play_strum_anim(animData-4, neneStrum, 0.45);
		
	buddyTarget = (nene if animData >= 4 else darnell);
	
	icon.texture = load("res://assets/images/icons/icon-%s.png"%[buddyTarget.curIcon]);
	healthBar.tint_under = Color("#ff000f") if GlobalOptions.updated_hud == "classic hud" else buddyTarget.healthBar_Color;
	
func funny_guy():
	darnell._playAnim("singLaugh");
	nene._playAnim("singLaugh");
	
func play_strum_anim(noteID, strum, timer):
	strum.get_child(noteID).reset_arrow_anim = timer;
	strum.get_child(noteID).play_note_anim("confirm");

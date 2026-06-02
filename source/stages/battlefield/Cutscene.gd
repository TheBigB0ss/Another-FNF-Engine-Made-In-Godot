extends Node2D

@onready var pico_anim = $"pico anim";
@onready var cutSceneBf = $BoyfriendCutscene;
@onready var tankmanCutscene = $Tankman;

var bf_anim;
var opponent_anim;
var gf_anim;
var camera;

var is_pico_part = false;
var song = "";

signal cutsceneEnding;

#FUCK THIS CUTSCENe >:(

func _ready() -> void:
	if !SongData.isStoryMode:
		self.hide();
		
func _process(_delta: float) -> void:
	if pico_anim.frame >= 182:
		pico_anim.frame = 169;
		
	if !SongData.isPlaying or song != "stress":
		return;
		
	if !is_pico_part:
		pico_anim.playing = true;
		if pico_anim.frame >= 28:
			pico_anim.frame = 0;
			
func ugh_intro():
	tankmanCutscene.show();
	camera.position = Vector2(280, 698);
	
	tankmanCutscene.frame = 0;
	tankmanCutscene.limit = 80;
	
	bf_anim.hide();
	opponent_anim.hide();
	SongData.is_not_in_cutscene = false;
	Global.is_on_video = true;
	
	#$AnimationPlayer.play("ugh");
	
	opponent_anim.hide();
	camera.zoom = Vector2(0.9, 0.9);
	
	await get_tree().create_timer(0.1).timeout;
	tankmanCutscene.playing = true;
	Sound.playAudio("week7_cutscene_voices/wellWellWell", false);
	
	await get_tree().create_timer(3.6).timeout
	tankmanCutscene.playing = false;
	camera.position = Vector2(1090, 801);
	
	await get_tree().create_timer(1).timeout
	bf_anim._playAnim("singUp");
	Sound.playAudio("week7_cutscene_voices/bfBeep", false);
	
	await get_tree().create_timer(0.8).timeout
	tankmanCutscene.frame = 81;
	tankmanCutscene.limit = 221;
	tankmanCutscene.playing = true;
	bf_anim._playAnim("idle dance");
	camera.position = Vector2(280, 698);
	Sound.playAudio("week7_cutscene_voices/killYou", false);
	
	await get_tree().create_timer(6).timeout;
	opponent_anim.show();
	camera.zoom = lerp(camera.zoom, Vector2(0.8, 0.8), 0.2);
	
	finish_cutscene();
	
func guns_intro():
	tankmanCutscene.show();
	tankmanCutscene.playing = true;
	tankmanCutscene.frame = 227;
	tankmanCutscene.limit = 506;
	
	cutSceneBf.hide();
	opponent_anim.hide();
	SongData.is_not_in_cutscene = false;
	Global.is_on_video = true;
	
	#$AnimationPlayer.play("guns");
	
	opponent_anim.hide();
	camera.zoom = Vector2(0.9, 0.9);
	
	await get_tree().create_timer(0.1).timeout
	camera.position = Vector2(280, 698);
	Sound.playAudio("week7_cutscene_voices/tankSong2", false);
	
	await get_tree().create_timer(4.3).timeout;
	gf_anim._playAnim("sad");
	
	await get_tree().create_timer(7.4).timeout
	gf_anim._playAnim("idle dance");
	opponent_anim.show();
	camera.zoom = lerp(camera.zoom, Vector2(0.8, 0.8), 0.2);
	
	finish_cutscene();
	
func stress_intro():
	tankmanCutscene.show();
	tankmanCutscene.playing = true;
	tankmanCutscene.frame = 507;
	tankmanCutscene.limit = 913;
	
	SongData.is_not_in_cutscene = false;
	Global.is_on_video = true;
	
	pico_anim.frame = 0;
	cutSceneBf.show();
	pico_anim.show();
	
	bf_anim.hide();
	gf_anim.hide();
	opponent_anim.hide();
	
	#$AnimationPlayer.play("stress");
	
	await get_tree().create_timer(0.1).timeout
	camera.position = Vector2(280, 698);
	Sound.playAudio("week7_cutscene_voices/stressCutscene", false);
	
	await get_tree().create_timer(13).timeout
	is_pico_part = true;
	camera.position = Vector2(715, 560);
	camera.position = pico_anim.position;
	pico_anim.playing = true;
	pico_anim.frame = 0;
	
	await get_tree().create_timer(0.8).timeout
	camera.position_smoothing_enabled = true;
	camera.zoom = lerp(camera.zoom, Vector2(1.65, 1.65), 0.09);
	
	await get_tree().create_timer(3.6).timeout
	camera.zoom = Vector2(0.8, 0.8);
	
	cutSceneBf.hide();
	bf_anim.z_index = 50;
	bf_anim.show();
	bf_anim._playAnim("catches");
	
	await get_tree().create_timer(2).timeout
	bf_anim._playAnim("idle dance");
	
	tankmanCutscene.playing = true;
	tankmanCutscene.frame = 916;
	tankmanCutscene.limit = 0;
	
	camera.position = Vector2(280, 698);
	
	await get_tree().create_timer(11.7).timeout
	tankmanCutscene.playing = false;
	camera.position_smoothing_enabled = false;
	camera.zoom = Vector2(1.25, 1.25);
	camera.position = Vector2(1090, 801);
	
	bf_anim._playAnim("singUp MISS");
	
	await get_tree().create_timer(0.8).timeout
	tankmanCutscene.playing = true;
	camera.position_smoothing_enabled = false;
	camera.zoom = Vector2(0.9, 0.9);
	camera.position = Vector2(280, 698);
	
	bf_anim._playAnim("idle dance");
	
	await get_tree().create_timer(4).timeout
	camera.position_smoothing_enabled = true;
	camera.zoom = lerp(camera.zoom, Vector2(0.8, 0.8), 0.2);
	
	finish_cutscene();
	
func finish_cutscene():
	bf_anim.show();
	opponent_anim.show();
	gf_anim.show();
	if song  == "stress":
		bf_anim.z_index = SongData.stageData["bf Z_Index"];
		
	self.emit_signal("cutsceneEnding");
	
func playGFAnim(anim):
	gf_anim._playAnim(anim);
	
func playBFAnim(anim):
	bf_anim._playAnim(anim);
	
func set_bf_visible():
	bf_anim.show();
	
func set_pico_part(toggle):
	is_pico_part = toggle;
	if toggle:
		pico_anim.frame = 0;
		
func set_cam_pos(x, y, smooth = true, zoom = Vector2.ONE):
	camera.position = Vector2(x, y);
	camera.position_smoothing_enabled = smooth;
	camera.zoom = lerp(camera.zoom, zoom, 0.10);
	

extends Node2D

@onready var rolling_tank = $rollingTankBg;
@onready var pico_anim = $"cutscenes/pico anim";
@onready var cutSceneBf = $cutscenes/BoyfriendCutscene;

var tank_angle = 0;
var pico_data = {};
var pico_note_array = [];
var song = "";

const tankmanPreload = preload("res://assets/stages/week7/tankmanKilled1.tscn");

func _ready() -> void:
	Conductor.connect("new_beat", beat_hit);
	MusicManager._stop_music();
	
	if SongData.isPlaying:
		song = SongData.week_songs[0].to_lower();
		
	if SongData.isPlaying:
		if song == "stress":
			var jsonFile = FileAccess.open("res://assets/data/songs/stress/picospeaker.json", FileAccess.READ);
			var jsonData = JSON.new();
			jsonData.parse(jsonFile.get_as_text());
			pico_data = jsonData.get_data();
			jsonFile.close();
			
			for i in pico_data["song"]["notes"]:
				for j in i["sectionNotes"]:
					pico_note_array.insert(0, [j[0], j[1], j[2]]);
					
			pico_note_array.sort_custom(Callable(self, "sort_notes"));
			
func sort_notes(a, b): 
	return a[0] < b[0];
	
func make_everyone_dance():
	$towerBg.play("watchtower gradient color instance 1");
	$tankBg0.play("fg tankhead far right instance 1");
	$tankBg1.play("fg tankhead 5 instance 1");
	$tankBg2.play("foreground man 3 instance 1");
	$tankBg3.play("fg tankhead 4 instance 1");
	$tankBg4.play("fg tankman bobbin 3 instance 1");
	$tankBg5.play("fg tankhead far right instance 1");
	
func set_new_z_index(index):
	for i in [$tankBg0, $tankBg1, $tankBg2, $tankBg3, $tankBg4, $tankBg5]:
		i.z_index = index;
		
func _process(delta):
	tank_angle += delta*0.1
	
	rolling_tank.position = Vector2(770 + cos(tank_angle) * 2200, 1680 + sin(tank_angle) * 1150);
	rolling_tank.rotation = tank_angle + PI/2;
	
	if pico_anim.frame >= 182:
		pico_anim.frame = 169;
		
	if !SongData.isPlaying or song != "stress":
		return;
		
	if !is_pico_part:
		pico_anim.playing = true;
		if pico_anim.frame >= 28:
			pico_anim.frame = 0;
			
	var pico_speaker = get_tree().current_scene.get("gf");
	if pico_speaker.curCharacter != "picoSpeaker":
		return;
		
	if pico_note_array.is_empty():
		return;
		
	if Conductor.getSongTime > pico_note_array[0][0]:
		var animData = (3 if pico_note_array[0][1] > 2 else 1) + (randi() % 2);
		pico_speaker._playAnim("shoot%s"%[animData]);
		
		var dead_tankmans = [];
		for i in pico_note_array:
			if Conductor.getSongTime >= i[0]:
				if !GlobalOptions.low_quality && int(randf_range(0, 110)) <= 25:
					var new_tankmen = tankmanPreload.instantiate();
					new_tankmen.position.y = 560 - randf_range(10, 35);
					new_tankmen.direction_right = i[1] < 2;
					new_tankmen.tankman_time = i[0];
					new_tankmen.is_dead = false;
					add_child(new_tankmen);
					
				dead_tankmans.append(i);
				
		for i in dead_tankmans:
			pico_note_array.erase(i);
			
var tankmanCutscene = null;
var is_pico_part = false;
func ugh_cutscene():
	set_hud(false);
	SongData.is_not_in_cutscene = false;
	Global.is_on_video = true;
	
	var bf_anim = get_tree().current_scene.get("bf");
	var opponent = get_tree().current_scene.get("dad");
	var camera = get_tree().current_scene.get("sectionCamera");
	
	opponent.hide();
	camera.zoom = Vector2(0.9, 0.9);
	
	reload_tankman("ugh");
	
	await get_tree().create_timer(0.1).timeout
	camera.position = Vector2(280, 698);
	tankmanCutscene.anim_to_play.play("TANK TALK 1 P1");
	Sound.playAudio("week7_cutscene_voices/wellWellWell", false);
	
	await get_tree().create_timer(3).timeout
	camera.position = Vector2(1090, 801);
	
	await get_tree().create_timer(1).timeout
	bf_anim._playAnim("singUp");
	Sound.playAudio("week7_cutscene_voices/bfBeep", false);
	
	await get_tree().create_timer(0.8).timeout
	bf_anim._playAnim("idle dance");
	camera.position = Vector2(280, 698);
	tankmanCutscene.anim_to_play.play("TANK TALK 1 P2");
	Sound.playAudio("week7_cutscene_voices/killYou", false);
	
	await get_tree().create_timer(6).timeout
	opponent.show();
	camera.zoom = lerp(camera.zoom, Vector2(0.8, 0.8), 0.2)
	start_song()
	
func guns_intro():
	set_hud(false);
	SongData.is_not_in_cutscene = false;
	Global.is_on_video = true;
	
	var bf_anim = get_tree().current_scene.get("bf");
	var gf_anim = get_tree().current_scene.get("gf");
	var opponent = get_tree().current_scene.get("dad");
	var camera = get_tree().current_scene.get("sectionCamera");
	
	opponent.hide();
	camera.zoom = Vector2(0.9, 0.9);
	
	reload_tankman("guns");
	
	await get_tree().create_timer(0.1).timeout
	camera.position = Vector2(280, 698);
	tankmanCutscene.anim_to_play.play("TANK TALK 2");
	Sound.playAudio("week7_cutscene_voices/tankSong2", false);
	
	await get_tree().create_timer(4.3).timeout
	gf_anim._playAnim("sad");
	
	await get_tree().create_timer(7.4).timeout
	gf_anim._playAnim("idle dance");
	opponent.show();
	camera.zoom = lerp(camera.zoom, Vector2(0.8, 0.8), 0.2);
	start_song();
	
func stress_intro():
	set_new_z_index(41);
	set_hud(false);
	SongData.is_not_in_cutscene = false;
	Global.is_on_video = true;
	
	cutSceneBf.show();
	cutSceneBf.z_index = 46;
	
	pico_anim.frame = 0;
	pico_anim.show();
	
	var bf_anim = get_tree().current_scene.get("bf");
	var gf_anim = get_tree().current_scene.get("gf");
	var opponent = get_tree().current_scene.get("dad");
	var camera = get_tree().current_scene.get("sectionCamera");
	
	bf_anim.z_index = 33;
	bf_anim.hide();
	gf_anim.hide();
	opponent.hide();
	
	reload_tankman("stress");
	tankmanCutscene.z_index = 41;
	
	await get_tree().create_timer(0.1).timeout
	camera.position = Vector2(280, 698);
	tankmanCutscene.anim_to_play.play("TANK TALK 3 P1 UNCUT");
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
	bf_anim.show();
	bf_anim._playAnim("catches");
	
	await get_tree().create_timer(2).timeout
	bf_anim._playAnim("idle dance");
	
	reload_tankman("stress2");
	tankmanCutscene.z_index = 41;
	
	tankmanCutscene.anim_to_play.play("TANK TALK 3 P2 UNCUT");
	camera.position = Vector2(280, 698);
	
	await get_tree().create_timer(11.7).timeout
	camera.position_smoothing_enabled = false;
	camera.zoom = Vector2(1.25, 1.25);
	camera.position = Vector2(1090, 801);
	
	bf_anim._playAnim("singUp MISS");
	
	await get_tree().create_timer(0.8).timeout
	camera.position_smoothing_enabled = false;
	camera.zoom = Vector2(0.9, 0.9);
	camera.position = Vector2(280, 698);
	
	bf_anim._playAnim("idle dance");
	
	await get_tree().create_timer(4).timeout
	camera.position_smoothing_enabled = true;
	camera.zoom = lerp(camera.zoom, Vector2(0.8, 0.8), 0.2);
	
	bf_anim.z_index = SongData.stageData["bf Z_Index"];
	
	opponent.show();
	pico_anim.hide();
	gf_anim.show();
	set_new_z_index(2);
	start_song();
	
func start_song():
	set_hud(true);
	for i in $tankmanCutscene.get_children():
		$tankmanCutscene.remove_child(i);
		i.queue_free();
		
	MusicManager._stop_music();
	SongData.is_not_in_cutscene = true;
	Global.is_on_video = false;
	Global.emit_signal("end_tankman_cutscene");
	
func reload_tankman(song):
	for i in $tankmanCutscene.get_children():
		$tankmanCutscene.remove_child(i);
		i.queue_free();
		
	tankmanCutscene = load("res://assets/stages/week7/cutscene/%s.tscn"%[song]).instantiate();
	tankmanCutscene.position = Vector2(312, 682);
	tankmanCutscene.z_index = 1;
	$tankmanCutscene.add_child(tankmanCutscene);
	
func set_hud(is_visible):
	var strums = get_tree().current_scene.get("game_strums")
	var hud = get_tree().current_scene.get("hud");
	strums.visible = is_visible;
	hud.visible = is_visible;
	
func beat_hit(beat):
	if beat % 2 == 0:
		make_everyone_dance();

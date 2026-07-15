extends Node2D

@onready var rolling_tank = $rollingTankBg;
@onready var cutsceneLoader = $Cutscene;

var tank_angle = 0;
var pico_data = {};
var pico_note_array = [];
var song = "";

const tankmanPreload = preload("res://source/stages/battlefield/TankmanSoldier.tscn");

signal end_tankman_cutscene;

func _ready() -> void:
	cutsceneLoader.connect("cutsceneEnding", start_song);
	
	cutsceneLoader.bf_anim = get_tree().current_scene.get("bf");
	cutsceneLoader.gf_anim = get_tree().current_scene.get("gf");
	cutsceneLoader.opponent_anim = get_tree().current_scene.get("dad");
	cutsceneLoader.camera = get_tree().current_scene.get("sectionCamera");
	
	Conductor.connect("new_beat", beat_hit);
	MusicManager._stop_music();
	
	if SongData.isPlaying:
		song = SongData.week_songs[0].to_lower();
		
	cutsceneLoader.song = song;
	
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
	$Soldiers/tankBg0.play("fg tankhead far right instance 1");
	$Soldiers/tankBg1.play("fg tankhead 5 instance 1");
	$Soldiers/tankBg2.play("foreground man 3 instance 1");
	$Soldiers/tankBg3.play("fg tankhead 4 instance 1");
	$Soldiers/tankBg4.play("fg tankman bobbin 3 instance 1");
	$Soldiers/tankBg5.play("fg tankhead far right instance 1");
	
func _process(delta):
	tank_angle += delta*0.1
	
	rolling_tank.position = Vector2(770 + cos(tank_angle) * 2200, 1680 + sin(tank_angle) * 1150);
	rolling_tank.rotation = tank_angle + PI/2;
	
	if !SongData.isPlaying or song != "stress":
		return;
		
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
			
func ugh_intro():
	set_hud(false);
	cutsceneLoader.ugh_intro();
	
func guns_intro():
	set_hud(false);
	cutsceneLoader.guns_intro();
	
func stress_intro():
	set_hud(false);
	cutsceneLoader.stress_intro();
	
func start_song():
	set_hud(true);
	
	cutsceneLoader.hide();
	
	MusicManager._stop_music();
	SongData.is_not_in_cutscene = true;
	Global.is_on_video = false;
	self.emit_signal("end_tankman_cutscene");
	
func set_hud(_is_visible):
	var strums = get_tree().current_scene.get("game_strums");
	var hud = get_tree().current_scene.get("hud");
	strums.visible = _is_visible;
	hud.visible = _is_visible;
	
func beat_hit(beat):
	if beat % 2 == 0:
		make_everyone_dance();

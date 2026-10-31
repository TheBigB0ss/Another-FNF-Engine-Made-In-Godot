extends Node

var chartData = {};
var stageData = {};
var eventsData = {};
var weeks_data = {};
var characters = {};
var camera_data = {};

var week = "";
var song = "":
	get:
		if song == "":
			return "bopeebo";
			
		return song;
		
	set(val):
		song = val.to_lower();
		
var stage = "":
	get:
		if stage == "":
			return "stage";
			
		return stage;
		
	set(val):
		if val.contains(" "):
			val = val.replace(" ", "_");
		stage = val.to_lower();
		
var songBpm = 100.0;
var songSpeed = 1.0;

var updated_chart = null;
var chart_dont_exist = false;

var player1 = "";
var player2 = "";
var gfPlayer = "";

var player1StagePosition = Vector2.ZERO;
var player1Zindex = 0;

var player2StagePosition = Vector2.ZERO;
var player2Zindex = 0;

var gfStagePosition = Vector2.ZERO;
var gfZindex = 0;

var stageZoom = Vector2.ZERO;
var stageZoomBeat = Vector2.ZERO;

var death_count = 0;
var isStoryMode = false;
var restartSong = false;
var is_in_cutscene = false;
var isPixelStage = false;
var needVoice = true;

var isOnPauseMode = false;
var isOnChartMode = false;
var isPlaying = false;
var isOnDeathScreen = false;

var songNotes = [];

var playerNotes = [];
var opponentNotes = [];

var songSections = [];
var songEvents = [];

var week_songs = []:
	set(val):
		week_songs = [val] if val is String else val;
		
var week_diffs = []:
	set(val):
		if val == "normal":
			val = "";
			
		week_diffs = val;
		
var week_folder_path = "default";
var weekName = "";

var stage_shader:ShaderMaterial = null;

func loadStageJson(new_stage):
	var path = "res://source/stages/%s/%s.json"%[new_stage, new_stage];
	
	if !FileAccess.file_exists(path):
		return;
		
	var file = FileAccess.open(path, FileAccess.READ);
	var data = JSON.parse_string(file.get_as_text());
	file.close();
	
	stageData = data;
	
	stageZoom = Vector2.ONE * float(stageData.get("stage zoom", 0.8));
	stageZoomBeat = Vector2.ONE * float(stageData.get("stage beat zoom", 0.83));
	
	var bf_pos = stageData.get("bf", [0, 0]);
	var opponent_pos = stageData.get("opponent", [0, 0]);
	var gf_pos = stageData.get("gf", [0, 0]);
	
	player1StagePosition = Vector2(bf_pos[0], bf_pos[1]);
	player1Zindex = stageData.get("bf Z_Index", 0);
	
	player2StagePosition = Vector2(opponent_pos[0], opponent_pos[1]);
	player2Zindex = stageData.get("opponent Z_Index", 0);
	
	gfStagePosition = Vector2(gf_pos[0], gf_pos[1]);
	gfZindex = stageData.get("gf Z_Index", 0);
	
func loadJson(new_song, difficulty = "", new_chart = null):
	playerNotes.clear();
	opponentNotes.clear();
	songSections.clear();
	
	characters.clear();
	camera_data.clear();
	
	var difficultyPath = ("res://assets/songs/%s/chart/%s.json"%[new_song, new_song]) if difficulty == "" or difficulty == "normal" else ("res://assets/songs/%s/chart/%s-%s.json"%[new_song, new_song, difficulty]);
	var eventsPath = "res://assets/songs/%s/chart/events.json"%[new_song];
	
	var chart_data = null;
	
	if new_chart != null:
		chart_data = new_chart;
	else:
		if !FileAccess.file_exists(difficultyPath):
			chart_dont_exist = true;
			return;
			
		var file = FileAccess.open(difficultyPath, FileAccess.READ);
		var json = JSON.new();
		var error = json.parse(file.get_as_text());
		file.close();
		
		if error != OK:
			chart_dont_exist = true;
			return;
			
		chart_data = json.data;
		
	chart_dont_exist = false;
	chartData = chart_data;
	
	var loader = ChartLoader.new();
	loader.load_chart(chartData, new_song, eventsPath);
	
	reload_section();
	
func get_stage_shader(_stage):
	for i in _stage.get_children():
		for j in i.get_children():
			if j is ColorRect && j.material != null && j.material is ShaderMaterial:
				return j.material.duplicate();
				
	return null;
	
#just for chart editor

var player_section_notes = {};
var opponent_section_notes = {};
var section_events = {};

func reload_section():
	player_section_notes.clear();
	opponent_section_notes.clear();
	section_events.clear();
	
	for i in songSections.size():
		player_section_notes[i] = [];
		opponent_section_notes[i] = [];
		section_events[i] = [];
		
	for note in playerNotes:
		var sec = Conductor.get_section(note[0]);
		
		if !player_section_notes.has(sec):
			player_section_notes[sec] = [];
			
		player_section_notes[sec].append(note);
		
	for note in opponentNotes:
		var sec = Conductor.get_section(note[0]);
		
		if !opponent_section_notes.has(sec):
			opponent_section_notes[sec] = [];
			
		opponent_section_notes[sec].append(note);
		
	for event in songEvents:
		var sec = Conductor.get_section(event[0]);
		
		if !section_events.has(sec):
			section_events[sec] = [];
			
		section_events[sec].append(event);
		
func get_section_notes(section):
	var notes = [];
	for note in playerNotes:
		if Conductor.get_section(note[0]) == section:
			notes.append(note);
			
	for note in opponentNotes:
		if Conductor.get_section(note[0]) == section:
			notes.append(note);
			
	return notes;
	
func get_note_array(noteData):
	return playerNotes if noteData >= 4 else opponentNotes;
	
func clear_section(section):
	playerNotes = playerNotes.filter(func(n): return Conductor.get_section(n[0]) != section);
	opponentNotes = opponentNotes.filter(func(n): return Conductor.get_section(n[0]) != section);
	

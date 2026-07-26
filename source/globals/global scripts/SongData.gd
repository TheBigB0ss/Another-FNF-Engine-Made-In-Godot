extends Node

var chartData = {};
var stageData = {};
var eventsData = {};

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
var is_not_in_cutscene = true;
var isPixelStage = false;
var needVoice = true;

var isOnPauseMode = false;
var isOnChartMode = false;
var isPlaying = false;
var isOnDeathScreen = false;

var songNotes = [];

var playerNotes = [];
var opponentNotes = [];
var extraOpponentNotes = [];

var songSections = [];
var songEvents = [];

var week_songs = []:
	set(val):
		week_songs = [val] if val is String else val;
	get:
		return week_songs;
		
var week_diffs = []:
	set(val):
		week_diffs = "" if val == "normal" else val;
	get:
		return week_diffs;
		
var weeks_data = {};

var week_folder_path = "default";
var weekName = "";

var characters = {};
var camera_data = {};

func loadStageJson(new_stage):
	var jsonFile = FileAccess.open("res://assets/data/stages data/%s.json"%[new_stage], FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	stageData = jsonData.get_data();
	jsonFile.close();
	
	set_stage_null_var("gf Z_Index", 0);
	set_stage_null_var("opponent Z_Index", 0);
	set_stage_null_var("bf Z_Index", 0);
	set_stage_null_var("stage zoom", 0.8);
	set_stage_null_var("stage beat zoom", 0.83);
	set_stage_null_var("new opponent", [0, 0]);
	set_stage_null_var("new opponent Z_Index", 0);
	set_stage_null_var("two opponents", false);
	
	stageZoomBeat = Vector2(stageData["stage beat zoom"], stageData["stage beat zoom"]);
	stageZoom = Vector2(stageData["stage zoom"], stageData["stage zoom"]);
	
	player1StagePosition = Vector2(SongData.stageData["bf"][0], SongData.stageData["bf"][1]);
	player1Zindex = stageData["bf Z_Index"];
	
	player2StagePosition = Vector2(SongData.stageData["opponent"][0], SongData.stageData["opponent"][1]);
	player2Zindex = stageData["opponent Z_Index"];
	
	gfStagePosition = Vector2(SongData.stageData["gf"][0], SongData.stageData["gf"][1]);
	gfZindex = stageData["gf Z_Index"];
	
func loadJson(new_song, difficulty = "", new_chart = null):
	playerNotes.clear();
	opponentNotes.clear();
	extraOpponentNotes.clear();
	songSections.clear();
	
	var difficultyPath = "";
	var eventsPath = "";
	
	difficultyPath = ("res://assets/data/songs/%s/%s.json"%[new_song, new_song]) if difficulty == "" or difficulty == "normal" else ("res://assets/data/songs/%s/%s-%s.json"%[new_song, new_song, difficulty]);
	eventsPath = "res://assets/data/songs/%s/events.json"%[new_song];
	
	var jsonFile = FileAccess.open(difficultyPath, FileAccess.READ);
	var jsonData = JSON.new();
	
	if FileAccess.file_exists(difficultyPath):
		chart_dont_exist = false;
		
		jsonData.parse(jsonFile.get_as_text());
		chartData = new_chart if new_chart != null else jsonData.get_data();
		jsonFile.close();
		
		if chartData.has("song"):
			convert_pyschChart(chartData, eventsPath);
		elif chartData.has("codenameChart"):
			convert_codenameChart(chartData, eventsPath);
		else:
			set_chart(chartData, eventsPath);
			
		reload_section();
	else:
		chart_dont_exist = true;
		
func set_stage_null_var(cool_var, new_value):
	if !stageData.has(cool_var):
		stageData[cool_var] = new_value;
		
func set_chart(songChart, eventsPath = ""):
	playerNotes.clear();
	opponentNotes.clear();
	extraOpponentNotes.clear();
	songSections.clear();
	
	stage = songChart["meta"]["stage"];
	song = songChart["meta"]["song"];
	
	isPixelStage = songChart["meta"]["isPixelStage"];
	needVoice = songChart["meta"]["needsVoices"];
	
	songBpm = songChart["meta"]["bpm"];
	songSpeed = songChart["meta"]["speed"];
	
	player1 = songChart["meta"]["player1"];
	player2 = songChart["meta"]["player2"];
	gfPlayer = songChart["meta"]["gfVersion"];
	
	for strum in songChart["strums"]:
		for i in strum["player"]:
			var note = [i[0], i[1], i[2], i[3], i[4] if i[4] != null else null, i[5] if i[5] != null else null];
			playerNotes.append(note);
			
		for i in strum["opponent"]:
			var note = [i[0], i[1], i[2], i[3], i[4] if i[4] != null else null, i[5] if i[5] != null else null];
			opponentNotes.append(note);
			
		if strum.has("extra") && strum["extra"] != []:
			for i in strum["extra"]:
				var note = [i[0], i[1], i[2], i[3], i[4] if i[4] != null else null, i[5] if i[5] != null else null];
				extraOpponentNotes.append(note);
				
	for i in songChart["sections"]:
		songSections.append(i);
		
	if !songChart["events"].is_empty():
		songEvents = songChart["events"];
		
	elif songChart["events"].is_empty() && FileAccess.file_exists(eventsPath):
		var eventsJsonFile = FileAccess.open(eventsPath, FileAccess.READ);
		var eventsJsonData = JSON.new();
		eventsJsonData.parse(eventsJsonFile.get_as_text());
		eventsData = eventsJsonData.get_data();
		eventsJsonFile.close();
		
		songEvents = eventsData["song"]["events"];
		
	elif songChart["events"].is_empty() && !FileAccess.file_exists(eventsPath):
		songEvents = [];
		
func convert_pyschChart(songChart, eventsPath = ""):
	playerNotes.clear();
	opponentNotes.clear();
	extraOpponentNotes.clear();
	songSections.clear();
	
	var templateChart = {
		"strums": [
			{
				"player": [],
				"opponent": [],
				"extra": []
			}
		],
		"sections": []
	};
	
	stage = songChart["song"].get("stage", "stage");
	song = songChart["song"]["song"];
	
	isPixelStage = songChart["song"].get("isPixelStage", false);
	needVoice = songChart["song"].get("needsVoices", false);
	
	songBpm = songChart["song"]["bpm"];
	songSpeed = songChart["song"]["speed"];
	
	player1 = songChart["song"]["player1"];
	player2 = songChart["song"]["player2"];
	gfPlayer = songChart["song"]["gfVersion"];
	
	for i in songChart["song"]["notes"].size():
		var section = songChart["song"]["notes"][i];
		
		templateChart["sections"].append({
			"lengthInSteps": section.get("lengthInSteps", 16),
			"altAnim": section.get("altAnim", false),
			"bpm": section.get("bpm", songChart["song"]["bpm"]),
			"changeBPM": section.get("changeBPM", false),
			"mustHitSection": section.get("mustHitSection", true),
			"gfSection": section.get("gfSection", false)
		});
		
		for j in section["sectionNotes"]:
			var note = {
				"noteTime": j[0],
				"noteData": int(j[1])%4,
				"noteLength": j[2],
				"noteType": j[3] if j.size() > 3 else "",
				"noteValue1": j[4] if j.size() > 4 else null,
				"noteValue2": j[5] if j.size() > 4 else null
			};
			
			if int(j[1]) < 4:
				if section["mustHitSection"]:
					templateChart["strums"][0]["player"].append(note);
				else:
					templateChart["strums"][0]["opponent"].append(note);
			elif int(j[1]) < 8:
				if section["mustHitSection"]:
					templateChart["strums"][0]["opponent"].append(note);
				else:
					templateChart["strums"][0]["player"].append(note);
			elif int(j[1]) >= 8:
				templateChart["strums"][0]["extra"].append(note);
				
	for i in templateChart["sections"]:
		songSections.append(i);
		
	for strum in templateChart["strums"]:
		for note in strum["player"]:
			playerNotes.append([note["noteTime"], note["noteData"], note["noteLength"], note["noteType"], note["noteValue1"], note["noteValue2"]]);
			
		for note in strum["opponent"]:
			opponentNotes.append([note["noteTime"], note["noteData"], note["noteLength"], note["noteType"], note["noteValue1"], note["noteValue2"]]);
			
		for note in strum["extra"]:
			extraOpponentNotes.append([note["noteTime"], note["noteData"], note["noteLength"], note["noteType"], note["noteValue1"], note["noteValue2"]]);
			
	if !songChart["song"].get("events", []).is_empty():
		songEvents = songChart["song"]["events"];
		
	elif songChart["song"].get("events", []).is_empty() && FileAccess.file_exists(eventsPath):
		var eventsJsonFile = FileAccess.open(eventsPath, FileAccess.READ);
		var eventsJsonData = JSON.new();
		eventsJsonData.parse(eventsJsonFile.get_as_text());
		eventsData = eventsJsonData.get_data();
		eventsJsonFile.close();
		
		songEvents = eventsData["song"]["events"];
		
	elif songChart["song"].get("events", []).is_empty() && !FileAccess.file_exists(eventsPath):
		songEvents = [];
		
func convert_codenameChart(songChart, songName, eventsPath = ""):
	playerNotes.clear();
	opponentNotes.clear();
	extraOpponentNotes.clear();
	songSections.clear();
	
	var metaData = {};
	var metaPath = "res://assets/data/songs/%s/meta.json"%[songName];
	if FileAccess.file_exists(metaPath):
		var metaJsonFile = FileAccess.open(eventsPath, FileAccess.READ);
		var metaJsonData = JSON.new();
		metaJsonData.parse(metaJsonFile.get_as_text());
		metaData = metaJsonData.get_data();
		metaJsonFile.close();
		
	elif songChart.has("meta"):
		metaData = songChart["meta"];
		
	stage = metaData.get("stage", "stage");
	song = metaData.get("name", metaData.get("displayName", songName));
	
	songBpm = metaData["bpm"];
	songSpeed = songChart.get("scrollSpeed", metaData.get("scrollSpeed", 1.0));
	
	var lastMustHit = false;
	var lastSection = 0;
	for strum in songChart["strumLines"]:
		for note in strum["notes"]:
			lastSection = max(lastSection, get_section(note["time"]));
			
	for i in lastSection + 1:
		songSections.append({
			"lengthInSteps": 16,
			"changeBPM": false,
			"bpm": songBpm,
			"mustHitSection": lastMustHit,
			"gfSection": false,
			"altAnim": false,
			"sectionNotes": []
		});
		
		lastMustHit = !lastMustHit;
		
	for strum in songChart["strumLines"]:
		match strum["position"]:
			"boyfriend":
				player1 = strum["characters"][0];
				for note in strum["notes"]:
					var newNote = [note["time"], note["id"], note["sLen"], songChart["noteTypes"][note["type"]-1] if note["type"] > 0 else "", null, null];
					playerNotes.append(newNote);
					
			"dad":
				player2 = strum["characters"][0];
				for note in strum["notes"]:
					var newNote = [note["time"], note["id"], note["sLen"], songChart["noteTypes"][note["type"]-1] if note["type"] > 0 else "", null, null];
					opponentNotes.append(newNote);
					
			"girlfriend":
				gfPlayer = strum["characters"][0];
				for note in strum["notes"]:
					var newNote = [note["time"], note["id"], note["sLen"], songChart["noteTypes"][note["type"]-1] if note["type"] > 0 else "", null, null];
					extraOpponentNotes.append(newNote);
					
			_:
				for note in strum["notes"]:
					var newNote = [note["time"], note["id"], note["sLen"], songChart["noteTypes"][note["type"]-1] if note["type"] > 0 else "", null, null];
					extraOpponentNotes.append(newNote);
					
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
		var sec = get_section(note[0]);
		player_section_notes[sec].append(note);
		
	for note in opponentNotes:
		var sec = get_section(note[0])
		opponent_section_notes[sec].append(note);
		
	for event in songEvents:
		var sec = get_section(event[0])
		section_events[sec].append(event);
		
func get_character_section_notes(section, notesArr):
	if notesArr == playerNotes:
		return player_section_notes.get(section, []);
		
	if notesArr == opponentNotes:
		return opponent_section_notes.get(section, []);
		
	if notesArr == songEvents:
		return section_events.get(section, []);
		
	return [];
	
func get_section_notes(section):
	var notes = [];
	for note in playerNotes:
		if get_section(note[0]) == section:
			notes.append(note);
			
	for note in opponentNotes:
		if get_section(note[0]) == section:
			notes.append(note);
			
	return notes;
	
func get_note_array(noteData):
	return playerNotes if noteData >= 4 else opponentNotes;
	
func clear_section(section):
	playerNotes = playerNotes.filter(func(n): return get_section(n[0]) != section);
	opponentNotes = opponentNotes.filter(func(n): return get_section(n[0]) != section);
	
func get_section(time):
	var bpmChangeMap = [];
	
	var curBPM = songBpm;
	var totalSteps = 0;
	var totalPos = 0.0;
	
	for section in songSections:
		if section["changeBPM"]:
			curBPM = section["bpm"];
			bpmChangeMap.append([totalSteps, totalPos, curBPM]);
			
		var sectionLength = section["lengthInSteps"];
		totalSteps += sectionLength;
		totalPos += ((60.0 / curBPM) * 1000.0 / 4.0) * sectionLength;
		
	var last_change = [0, 0, songBpm];
	for i in bpmChangeMap:
		if i[1] <= time:
			last_change = i;
		else:
			break;
			
	var crochet = (60.0 / last_change[2]) * 1000.0;
	var stepCrochet = crochet / 4.0;
	var step = last_change[0] + floor((time - last_change[1]) / stepCrochet);
	return int(floor(step/16));

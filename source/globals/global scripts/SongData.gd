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
		stage = val.to_lower();
		
var songBpm = 100.0;
var songSpeed = 1.0;

var updated_chart = null;
var chart_dont_exist = false;

var player1 = "";
var player2 = "";
var gfPlayer = "";
var player3 = "";

var player1StagePosition = Vector2.ZERO;
var player1Zindex = 0;

var player2StagePosition = Vector2.ZERO;
var player2Zindex = 0;

var player3StagePosition = Vector2.ZERO;
var player3Zindex = 0;

var gfStagePosition = Vector2.ZERO;
var gfZindex = 0;

var stageZoom = Vector2.ZERO;
var stageZoomBeat = Vector2.ZERO;

var haveTwoOpponents = false;
var isPixelStage = false;
var needVoice = true;

var songNotes = [];
var songEvents = [];

func loadStageJson(stage):
	var jsonFile = FileAccess.open("res://assets/stages/data/%s.json"%[stage], FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	stageData = jsonData.get_data();
	jsonFile.close();
	
	set_stage_null_var("gf Z_Index", 0);
	set_stage_null_var("opponent Z_Index", 0);
	set_stage_null_var("bf Z_Index", 0);
	set_stage_null_var("stage zoom", 0.8);
	set_stage_null_var("stage beat zoom", 0.83);
	
	stageZoomBeat = Vector2(stageData["stage beat zoom"], stageData["stage beat zoom"]);
	stageZoom = Vector2(stageData["stage zoom"], stageData["stage zoom"]);
	
	player1StagePosition = Vector2(SongData.stageData["bf"][0], SongData.stageData["bf"][1]);
	player1Zindex = stageData["bf Z_Index"];
	
	player2StagePosition = Vector2(SongData.stageData["opponent"][0], SongData.stageData["opponent"][1]);
	player2Zindex = stageData["opponent Z_Index"];
	
	player3StagePosition = Vector2(SongData.stageData["opponent"][0], SongData.stageData["opponent"][1]);
	player3Zindex = stageData["opponent Z_Index"];
	
	gfStagePosition = Vector2(SongData.stageData["gf"][0], SongData.stageData["gf"][1]);
	gfZindex = stageData["gf Z_Index"];
	
func loadJson(new_song, difficulty = "", new_chart = null):
	var new_chart_data = new_chart;
	var difficultyPath = "";
	var eventsPath = "";
	
	var null_vars = {
		"events": [],
		"speed": 1,
		"bpm": 100,
		"two opponents": false,
		"player3": "none",
		"stage": "stage",
		"song": "bopeebo",
		"isPixelStage": false,
	};
	
	var sections_null_vars = {
		"altAnim": false,
		"bpm": 0.0,
		"changeBPM": false,
		"gfSection": false,
		"lengthInSteps": 16.0,
		"mustHitSection": true,
		"sectionNotes": []
	};
	
	difficultyPath = ("res://assets/data/%s/%s.json"%[new_song, new_song]) if difficulty == "" or difficulty == "normal" else ("res://assets/data/%s/%s-%s.json"%[new_song, new_song, difficulty]);
	eventsPath = "res://assets/data/%s/events.json"%[new_song];
	
	var jsonFile = FileAccess.open(difficultyPath, FileAccess.READ);
	var jsonData = JSON.new();
	
	var eventsJsonFile = FileAccess.open(eventsPath, FileAccess.READ);
	var eventsJsonData = JSON.new();
	
	if FileAccess.file_exists(difficultyPath):
		chart_dont_exist = false;
		
		jsonData.parse(jsonFile.get_as_text());
		chartData = new_chart if new_chart_data != null else jsonData.get_data();
		jsonFile.close();
		
		for i in null_vars.keys():
			set_null_var(i, null_vars[i]);
			
		for i in sections_null_vars.keys():
			set_section_null_var(i, sections_null_vars[i]);
			
		for i in chartData["song"]["notes"].size():
			for j in chartData["song"]["notes"][i]["sectionNotes"].size():
				if chartData["song"]["notes"][i]["sectionNotes"][j].size() < 4:
					chartData["song"]["notes"][i]["sectionNotes"][j].append("");
					
		songNotes = chartData["song"]["notes"];
		if !chartData["song"]["events"].is_empty():
			songEvents = chartData["song"]["events"];
			
		elif chartData["song"]["events"].is_empty() && FileAccess.file_exists(eventsPath):
			eventsJsonData.parse(eventsJsonFile.get_as_text());
			eventsJsonFile.close();
			eventsData = eventsJsonData.get_data();
			songEvents = eventsData["song"]["events"];
			
		elif chartData["song"]["events"].is_empty() && !FileAccess.file_exists(eventsPath):
			songEvents = [];
			
		stage = chartData["song"]["stage"];
		song = chartData["song"]["song"];
		
		haveTwoOpponents = chartData["song"]["two opponents"];
		isPixelStage = chartData["song"]["isPixelStage"];
		needVoice = chartData["song"]["needsVoices"];
		
		songBpm = chartData["song"]["bpm"];
		songSpeed = chartData["song"]["speed"];
		
		player1 = chartData["song"]["player1"];
		player2 = chartData["song"]["player2"];
		player3 = chartData["song"]["player3"];
		gfPlayer = chartData["song"]["gfVersion"];
		
	else:
		chart_dont_exist = true;
		
func set_section_null_var(cool_var, new_value):
	for i in chartData["song"]["notes"]:
		if !i.has(cool_var):
			i[cool_var] = new_value;
			
func set_null_var(cool_var, new_value):
	if !chartData["song"].has(cool_var):
		chartData["song"][cool_var] = new_value;
		
func set_stage_null_var(cool_var, new_value):
	if !stageData.has(cool_var):
		stageData[cool_var] = new_value;

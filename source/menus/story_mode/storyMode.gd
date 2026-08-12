extends Node2D

@onready var locker = $'lock';

@onready var weekTitle = $'texts/weekName';
@onready var weeksSpr = $'bgs/WeekSprite';
@onready var songText = $'texts/songs';
@onready var scoreText = $'texts/score';

@onready var menu_bf = $'characters/characterPosition1';
@onready var menu_gf = $'characters/characterPosition2';
@onready var menu_opponent = $'characters/characterPosition3';

@onready var diffSpr = $'difficulties';

@onready var leftArrow = $'arrows/LeftArrow';
@onready var rightArrow = $'arrows/RightArrow';

var yellowBf = null;
var yellowGf = null;
var yellowOpponent = null;

var noSpam = false;
var diffs = ["easy", "normal", "hard"];
var curDiff = 0;

var weeks = [];

var curWeek = 0;

var offSetShit = 0;
var coolOffset = 115;

var score = 0;
var week_score = 0;

func get_week_files():
	var file = [];
	var coolFolder = DirAccess.open("res://assets/data/weeks data/%s"%[SongData.week_folder_path]);
	if coolFolder:
		coolFolder.list_dir_begin();
		var nameShit = coolFolder.get_next();
		while nameShit != "":
			file.append(nameShit.replace(".json", ""));
			nameShit = coolFolder.get_next();
			
	return file;
	
func loadJson(_week):
	var jsonFile = FileAccess.open("res://assets/data/weeks data/%s/%s.json"%[SongData.week_folder_path, _week],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	jsonFile.close();
	return jsonData.get_data();
	
var diffTexs = {};

func _ready():
	Discord.update_discord_info("story menu", "Is in menus");
	
	Conductor.reset();
	Conductor.connect("new_beat", beat_hit);
	
	for i in get_week_files():
		var data = loadJson(i);
		if data["hideFromStoryMode"]:
			continue;
			
		weeks.append(data);
		
	for i in weeks:
		var weekName = i["weekName"];
		
		var storySprite = Sprite2D.new();
		storySprite.texture = load("res://assets/images/story mode/titles/%s.png"%[weekName]);
		storySprite.position.y = offSetShit;
		weeksSpr.add_child(storySprite);
		offSetShit += coolOffset;
		
	weeksSpr.position.y = float(480-coolOffset*curWeek);
	
	for i in ["easy", "normal", "hard", "remix"]:
		diffTexs[i] = load("res://assets/images/story mode/difficulties/%s.png"%[i]);
		
	for i in weeks:
		var weekName = i["weekName"];
		
		if !HighScore.week_status.has(weekName):
			HighScore.week_status[weekName] = i["isLocked"];
			HighScore.save_week_status();
			
	var changed = false;
	for i in weeks:
		var weekName = i["weekName"];
		
		if !HighScore.week_status.has(weekName):
			HighScore.week_status[weekName] = i["isLocked"];
			changed = true;
			
	if changed:
		HighScore.save_week_status();
		
	SongData.weeks_data = weeks;
	
	changeMenuCharacter();
	changeDiff(1);
	changeWeek(Global.current_selected["storyMode"]);
	
var choiced = false;
func _input(ev):
	if ev is InputEventKey:
		if Global.can_use_menus:
			if ev.keycode in [GlobalOptions.get_key("escape")] && ev.pressed && !ev.echo:
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
			if ev.keycode in [GlobalOptions.get_key("ui_down")] && ev.pressed && !noSpam && !ev.echo:
				changeWeek(1);
				
			if ev.keycode in [GlobalOptions.get_key("ui_up")] && ev.pressed && !noSpam && !ev.echo:
				changeWeek(-1);
				
			if SongData.chart_dont_exist && $warning.visible:
				if (ev.keycode in [GlobalOptions.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && ev.pressed && !ev.echo:
					$warning.visible = false;
					noSpam = false;
			else:
				if (ev.keycode in [GlobalOptions.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && ev.pressed && !noSpam && !ev.echo:
					go_to_week();
					
			if ev.keycode in [GlobalOptions.get_key("ui_left")] && !noSpam && ev.pressed && !ev.echo:
				leftArrow.play("leftConfirm");
				changeDiff(-1);
			else:
				leftArrow.play("leftIdle");
				
			if ev.keycode in [GlobalOptions.get_key("ui_right")] && !noSpam && ev.pressed && !ev.echo:
				rightArrow.play("rightConfirm");
				changeDiff(1);
			else:
				rightArrow.play("rightIdle");
				
var confirm_timer = 0.075;
func _process(delta):
	Conductor.getSongTime += delta * 1000.0;
	weeksSpr.position.y = lerp(float(weeksSpr.position.y), float(480-coolOffset*curWeek), 1.0 - exp(-12.0 * delta));
	
	if !choiced:
		return;
		
	confirm_timer -= delta;
	if confirm_timer <= 0:
		weeksSpr.get_child(curWeek).modulate = (Color.WHITE if weeksSpr.get_child(curWeek).modulate == Color.CYAN else Color.CYAN);
		confirm_timer = 0.075;
		
	scoreText.text = "Week Score: %s"%[week_score];
	
func go_to_week():
	var is_unlocked = HighScore.unlockweek(weeks[curWeek]["lastWeek"], weeks[curWeek]["lastWeek"], weeks[curWeek]["weekName"], weeks[curWeek]["isLocked"]);
	
	if !is_unlocked:
		Sound.playAudio("cancelMenu", false);
		return;
		
	noSpam = true;
	
	var storyMode = true;
	var songsList = [];
	var diffsList = [];
	var songPath = "";
	
	for i in weeks[curWeek]["songs"]:
		songsList.append(i[0]);
		diffsList = diffs[curDiff if !curDiff > diffs.size()-1 else 0];
		
	SongData.week_songs = songsList;
	SongData.week_diffs = diffsList;
	SongData.isStoryMode = storyMode;
	SongData.weekName = weeks[curWeek]["weekName"];
	SongData.week = weeks[curWeek]["weekName"] if curWeek < weeks.size() else ""
	
	songPath = songsList[0];
	SongData.loadJson(songPath, diffsList);
	
	if SongData.chart_dont_exist:
		choiced = false;
		$warning.visible = true;
		
		var difficultyPath = ("res://assets/songs/%s/chart/%s.json"%[songPath, songPath]) if diffsList == "" or diffsList == "normal" else ("res://assets/songs/%s/chart/%s-%s.json"%[songPath, songPath, diffsList]);
		$warning/Label.text = "Missing Chart:\n%s"%[difficultyPath];
		Sound.playAudio("cancelMenu", false);
		
		return;
		
	choiced = true;
	Sound.playAudio("confirmMenu", false);
	
	if weeks[curWeek]["weekCharacters"][1] == "BF":
		menu_bf.get_child(0).play("confirm");
		
	await get_tree().create_timer(1).timeout;
	Global.changeScene("gameplay/PlayState", true, false);
	MusicManager._stop_music();
	
func changeDiff(shit):
	var is_unlocked = HighScore.unlockweek(weeks[curWeek]["lastWeek"], weeks[curWeek]["lastWeek"], weeks[curWeek]["weekName"], weeks[curWeek]["isLocked"]);
	
	if !is_unlocked:
		return;
		
	curDiff += shit;
	curDiff = wrapi(curDiff, 0, len(diffs));
	diffSpr.texture = diffTexs[diffs[curDiff]];
	
	update_weekScore();
	
func update_weekScore():
	week_score = 0;
	var diff = diffs[curDiff if !curDiff > diffs.size()-1 else 0];
	
	for i in weeks[curWeek]["songs"]:
		var suffix = "";
		if diff != "normal":
			suffix = "-" + diff.to_lower();
			
		week_score += HighScore.get_score(i[0], suffix);
		
func changeWeek(shit):
	Sound.playAudio("scrollMenu", false);
	
	curWeek += shit;
	curWeek = wrapi(curWeek, 0, len(weeks));
	Global.currentStoryMode = curWeek;
	
	for j in weeks.size():
		weeksSpr.get_child(j).modulate.a = 1 if j == curWeek else 0.5;
		
	updateWeek();
	
func updateWeek():
	SongData.weeks_data = weeks;
	
	var is_unlocked = HighScore.unlockweek(weeks[curWeek]["lastWeek"], weeks[curWeek]["lastWeek"], weeks[curWeek]["weekName"], weeks[curWeek]["isLocked"]);
	
	diffs = ["easy", "normal", "hard"] if weeks[curWeek]["weekDifficulties"].is_empty() else weeks[curWeek]["weekDifficulties"]
	diffSpr.texture = diffTexs[diffs[curDiff if !curDiff > diffs.size()-1 else 0]];
	
	locker.visible = !is_unlocked;
	leftArrow.visible = is_unlocked;
	rightArrow.visible = is_unlocked;
	diffSpr.visible = is_unlocked;
	
	weeksSpr.get_child(curWeek).modulate = Color.GRAY if !is_unlocked else Color.WHITE;
	
	songText.text = '';
	for i in weeks[curWeek]["songs"]:
		if !is_unlocked:
			songText.text = "???";
			continue;
			
		songText.text += i[0].to_upper()+"\n";
		if songText.text.contains("-"):
			songText.text = songText.text.replace("-", " ");
			
	weekTitle.text = "week locked" if !is_unlocked else weeks[curWeek]["weekDescription"];
	
	changeMenuCharacter();
	update_weekScore();
	
	for i in [menu_gf, menu_bf, menu_opponent]:
		if i.get_child(0) == null:
			continue;
			
		i.get_child(0).modulate = Color("#000000") if !is_unlocked else Color("#ffffff");
		
func changeMenuCharacter():
	var yellow_fellas = {
		"bf": [menu_bf, 1],
		"gf": [menu_gf, 2],
		"opponent": [menu_opponent, 0]
	};
	
	for i in yellow_fellas.keys():
		var char_grp = yellow_fellas[i][0];
		var charName = weeks[curWeek]["weekCharacters"][yellow_fellas[i][1]];
		
		if charName == "":
			if char_grp.get_child(0) != null:
				char_grp.get_child(0).queue_free();
				
			continue;
			
		if char_grp.get_child_count() > 0:
			if char_grp.get_child(0) == null:
				continue;
				
			var curChar = char_grp.get_child(0);
			
			if charName == curChar.name:
				continue;
				
			curChar.queue_free();
			
		var path = "res://source/menus/story_mode/characters/Menu_%s.tscn"%[charName];
		var new_char = load(path).instantiate();
		new_char.name = charName;
		char_grp.add_child(new_char);
		char_grp.show();
		
func beat_hit(beat):
	for i in [menu_bf, menu_gf, menu_opponent]:
		if !is_instance_valid(i.get_child(0)):
			continue;
			
		if beat % 2 == 0 && i.get_child(0).xmlList.keys()[i.get_child(0).animation] != "confirm":
			i.get_child(0).play("idle");
			

extends weekStuff

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

var week = [];

var new_weeks = [];
var last_weeks = [];
var songs_weeks = [];
var locked_weeks = [];
var week_difficulties = [];
var week_description = [];
var week_chars = [];

var curWeek = 0;

var offSetShit = 0;
var coolOffset = 115;

var score = 0;
var week_score = 0;

func loadJson(week):
	var jsonFile = FileAccess.open("res://assets/data/weeks data/%s/%s.json"%[SongData.week_folder_path, week],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	weekJson = jsonData.get_data();
	jsonFile.close();
	return weekJson;
	
func _ready():
	Discord.update_discord_info("story menu", "Is in menus")
	
	SongData.weeks_data = weekJson;
	
	week = get_week_files();
	for i in week:
		loadJson(i);
		if !weekJson["hideFromStoryMode"]:
			new_weeks.append(weekJson["weekName"]);
			last_weeks.append(weekJson["lastWeek"]);
			songs_weeks.append(weekJson["songs"]);
			locked_weeks.append(weekJson["isLocked"]);
			week_difficulties.append(weekJson["weekDifficulties"]);
			week_description.append(weekJson["weekDescription"]);
			week_chars.append(weekJson["weekCharacters"]);
			
	for i in new_weeks:
		var storySprite = Sprite2D.new();
		storySprite.texture = load("res://assets/images/weeks/%s.png"%[i]);
		storySprite.position.y = offSetShit;
		weeksSpr.add_child(storySprite);
		offSetShit += coolOffset
		
	weeksSpr.position.y = float(480-coolOffset*curWeek);
	
	for i in new_weeks.size():
		if !HighScore.week_status.has(new_weeks[i]):
			HighScore.week_status[new_weeks[i]] = locked_weeks[i];
			HighScore.save_week_status();
			
	changeMenuCharacter();
	changeDiff(1);
	changeWeek(Global.cur_thing);
	
var choiced = false;
func _input(ev):
	if ev is InputEventKey:
		if Global.can_use_menus:
			if ev.keycode in [Global.get_key("escape")] && ev.pressed && !ev.echo:
				Global.cur_thing = 0;
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
			if ev.keycode in [Global.get_key("ui_down")] && ev.pressed && !noSpam && !ev.echo:
				changeWeek(1);
				
			if ev.keycode in [Global.get_key("ui_up")] && ev.pressed && !noSpam && !ev.echo:
				changeWeek(-1);
				
			if SongData.chart_dont_exist && $warning.visible:
				if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && ev.pressed && !ev.echo:
					$warning.visible = false;
					noSpam = false;
			else:
				if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && ev.pressed && !noSpam && !ev.echo:
					go_to_week();
					
			if ev.keycode in [Global.get_key("ui_left")] && !noSpam && ev.pressed && !ev.echo:
				leftArrow.play("arrow push left");
				changeDiff(-1);
			else:
				leftArrow.play("arrow left");
				
			if ev.keycode in [Global.get_key("ui_right")] && !noSpam && ev.pressed && !ev.echo:
				rightArrow.play("arrow push right");
				changeDiff(1);
			else:
				rightArrow.play("arrow right");
				
var confirm_timer = 0.075;
var can_change_color = false;
func _process(delta):
	weeksSpr.position.y = lerp(float(weeksSpr.position.y), float(480-coolOffset*curWeek), 0.23);
	
	if choiced:
		confirm_timer -= delta;
		if confirm_timer <= 0:
			if can_change_color:
				weeksSpr.get_child(curWeek).modulate = Color.CYAN;
				can_change_color = false;
			else:
				weeksSpr.get_child(curWeek).modulate = Color.WHITE;
				can_change_color = true;
				
			confirm_timer = 0.075;
			
	scoreText.text = "Week Score: %s"%[week_score];
	
func go_to_week():
	var is_unlocked = HighScore.unlockweek(last_weeks[curWeek], last_weeks[curWeek], new_weeks[curWeek], locked_weeks[curWeek]);
	
	if is_unlocked:
		noSpam = true;
		
		var storyMode = true;
		var songsList = [];
		var diffsList = [];
		var songPath = "";
		
		for i in songs_weeks[curWeek]:
			songsList.append(i[0]);
			diffsList = diffs[curDiff if !curDiff > diffs.size()-1 else 0];
			
		SongData.week_songs = songsList;
		SongData.week_diffs = diffsList;
		SongData.isStoryMode = storyMode;
		SongData.weekName = new_weeks[curWeek];
		
		if !curWeek > new_weeks.size()-1:
			SongData.week = new_weeks[curWeek];
		else:
			SongData.week = "";
			
		songPath = songsList[0];
		SongData.loadJson(songPath, diffsList);
		
		if !SongData.chart_dont_exist:
			choiced = true;
			Sound.playAudio("confirmMenu", false);
			
			if week_chars[curWeek][1] == "BF":
				menu_bf.get_child(0).play("M bf HEY");
				
			await get_tree().create_timer(1).timeout;
			Global.changeScene("gameplay/PlayState", true, false);
			MusicManager._stop_music();
		else:
			choiced = false;
			$warning.visible = true;
			
			var difficultyPath = "";
			if diffsList == "" or diffsList == "normal":
				difficultyPath = "res://assets/data/songs/%s/%s.json"%[songPath, songPath];
			else:
				difficultyPath = "res://assets/data/song/%s/%s-%s.json"%[songPath, songPath, diffsList];
				
			$warning/Label.text = "Missing Chart:\n%s"%[difficultyPath];
			Sound.playAudio("cancelMenu", false);
	else:
		Sound.playAudio("cancelMenu", false);
		
func changeDiff(shit):
	week_score = 0;
	var is_unlocked = HighScore.unlockweek(last_weeks[curWeek], last_weeks[curWeek], new_weeks[curWeek], locked_weeks[curWeek]);
	
	if is_unlocked:
		curDiff += shit;
		curDiff = wrapi(curDiff, 0, len(diffs));
		diffSpr.texture = load("res://assets/images/difficulties/%s.png"%[diffs[curDiff]]);
		
		var tw = get_tree().create_tween();
		if diffSpr.texture.get_width() < 250:
			tw.tween_property(leftArrow, "position", Vector2(811,480), 0.02);
			tw.tween_property(rightArrow, "position", Vector2(1073,480), 0.02);
		else:
			tw.tween_property(leftArrow, "position", Vector2(763,480), 0.02);
			tw.tween_property(rightArrow, "position", Vector2(1125,480), 0.02);
			
	for i in songs_weeks[curWeek]:
		week_score += HighScore.get_score(i[0], "" if diffs[curDiff if !curDiff > diffs.size()-1 else 0] == "normal" else str("-", diffs[curDiff if !curDiff > diffs.size()-1 else 0].to_lower()))
		
func changeWeek(shit):
	week_score = 0;
	curWeek += shit;
	Sound.playAudio("scrollMenu", false);
	curWeek = wrapi(curWeek, 0, len(new_weeks));
	Global.cur_thing = curWeek;
	updateWeek();
	
	for j in new_weeks.size():
		weeksSpr.get_child(j).modulate.a = 1 if j == curWeek else 0.5;
		
func updateWeek():
	changeMenuCharacter();
	
	SongData.weeks_data = weekJson;
	
	var is_unlocked = HighScore.unlockweek(last_weeks[curWeek], last_weeks[curWeek], new_weeks[curWeek], locked_weeks[curWeek]);
	var is_locked = !is_unlocked;
	
	songText.text = '';
	weekTitle.text = '';
	
	diffs = ["easy", "normal", "hard"] if week_difficulties[curWeek] == [] else week_difficulties[curWeek];
	
	diffSpr.texture = load("res://assets/images/difficulties/%s.png"%[diffs[curDiff if !curDiff > diffs.size()-1 else 0]]);
	var tw = get_tree().create_tween();
	if diffSpr.texture.get_width() < 250:
		tw.tween_property(leftArrow, "position", Vector2(811,480), 0.02);
		tw.tween_property(rightArrow, "position", Vector2(1073,480), 0.02);
	else:
		tw.tween_property(leftArrow, "position", Vector2(763,480), 0.02);
		tw.tween_property(rightArrow, "position", Vector2(1125,480), 0.02);
		
	locker.visible = is_locked;
	leftArrow.visible = !is_locked;
	rightArrow.visible = !is_locked;
	diffSpr.visible = !is_locked;
	weeksSpr.get_child(curWeek).modulate = Color.GRAY if is_locked else Color.WHITE;
	
	songText.text = "???" if is_locked else "";
	
	for i in songs_weeks[curWeek]:
		if is_unlocked:
			songText.text += i[0].to_upper()+"\n";
			if songText.text.contains("-"):
				songText.text = songText.text.replace("-", " ");
				
	weekTitle.text = "week locked" if !is_unlocked else week_description[curWeek];
	
	for i in songs_weeks[curWeek]:
		week_score += HighScore.get_score(i[0], "" if diffs[curDiff if !curDiff > diffs.size()-1 else 0] == "normal" else str("-", diffs[curDiff if !curDiff > diffs.size()-1 else 0].to_lower()));
		
	menu_gf.modulate = Color("#000000") if !is_unlocked else Color("#ffffff");
	menu_bf.modulate = Color("#000000") if !is_unlocked else Color("#ffffff");
	menu_opponent.modulate = Color("#000000") if !is_unlocked else Color("#ffffff");
	
func changeMenuCharacter():
	var yellow_fellas = {
		"bf": [yellowBf, menu_bf, 1],
		"gf": [yellowGf, menu_gf, 2],
		"opponent": [menu_opponent, menu_opponent, 0]
	};
	
	for i in yellow_fellas.keys():
		var char = yellow_fellas[i][0];
		var char_grp = yellow_fellas[i][1];
		var char_index = yellow_fellas[i][2];
		
		if char_grp != null:
			for j in char_grp.get_children():
				char_grp.remove_child(j);
				j.queue_free();
				
		if week_chars[curWeek][char_index] != "" && week_chars[curWeek][char_index] != null:
			char = load("res://assets/images/weekCharacters/Menu_%s.tscn"%[week_chars[curWeek][char_index]]).instantiate();
			char_grp.add_child(char);
			char_grp.show();
		else:
			char_grp.hide();

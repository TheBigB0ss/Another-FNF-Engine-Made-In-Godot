extends weekStuff

@onready var song_stuff = $'songs';
@onready var icons_stuff = $'icons';

var cur_song = 0;
var cur_diff = 0;

var weeks = [];
var diffs = ["easy", "normal", "hard"];

var songs = [];
var bg_colors = [];
var icons = [];

var week_difficulties = [];
var cool_weeks = [];

var cur_score = 0;
var score = 0;
var rank = "";
var percent = 0.0;

var noSpam = false;

var offSetShit = 0;
var coolOffset = 140;

var dont_have_chart = false;

func loadJson(week):
	var jsonFile = FileAccess.open("res://assets/data/weeks data/%s/%s.json"%[SongData.week_folder_path, week],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	weekJson = jsonData.get_data();
	jsonFile.close();
	return weekJson;
	
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
	
func _ready() -> void:
	Conductor.reset();
	Conductor.getSongTime = 0.0;
	Conductor.connect("new_beat", beat_hit);
	
	Discord.update_discord_info("freeplay menu", "Is in menus");
	
	weeks = get_week_files();
	for i in weeks:
		loadJson(i);
		
		for j in weekJson["songs"]:
			if !weekJson["hideFromFreeplay"]:
				var new_song = j[0];
				var new_icon = j[1];
				var new_color = j[2];
				var new_weekName = weekJson["weekName"];
				var new_weekDifficult = weekJson["weekDifficulties"];
				
				add_song(new_song, new_icon, new_color, new_weekName, new_weekDifficult);
				
	for i in HighScore.unlockSongs:
		var new_song = i;
		var new_icon = HighScore.unlockSongs[i]["icon"];
		var new_color = HighScore.unlockSongs[i]["color"];
		var new_weekName = HighScore.unlockSongs[i]["week name"];
		var new_weekDifficult = HighScore.unlockSongs[i]["diffs"];
		
		add_song(new_song, new_icon, new_color, new_weekName, new_weekDifficult);
		
	song_stuff.position.y = float(350-coolOffset*Global.cur_thing);
	icons_stuff.position.y = float(350-coolOffset*Global.cur_thing);
	$bg.modulate = Color(bg_colors[cur_song][0], bg_colors[cur_song][1], bg_colors[cur_song][2]);
	
	change_song(Global.cur_thing);
	changeDiff(1);
	
func add_song(new_song, new_icon, new_color, new_week, diff):
	songs.append(new_song);
	icons.append(new_icon);
	bg_colors.append(new_color);
	cool_weeks.append(new_week);
	week_difficulties.append(diff);
	
	if new_song.contains("-"):
		new_song = new_song.replace("-", " ");
		
	var alphabet = Alphabet.new();
	alphabet._creat_word(new_song);
	alphabet.position.y += offSetShit;
	song_stuff.add_child(alphabet);
	
	var icon = freeplayIcon.new();
	icon.alphabet = alphabet;
	icon.new_x = 100;
	icon.load_icon(new_icon);
	icons_stuff.add_child(icon);
	
	offSetShit += coolOffset;
	
func _process(delta):
	Conductor.getSongTime += delta*1000;
	
	song_stuff.position.y = lerp(float(song_stuff.position.y), float(350-coolOffset*cur_song), 0.18);
	icons_stuff.position.y = lerp(float(icons_stuff.position.y), float(350-coolOffset*cur_song), 0.18);
	$bg.modulate = lerp($bg.modulate, Color(bg_colors[cur_song][0], bg_colors[cur_song][1], bg_colors[cur_song][2]), 0.075);
	
	cur_score = lerp(int(cur_score), int(score), 0.7);
	
	var diff_id = cur_diff if cur_diff <= diffs.size() - 1 else 0;
	var diff_name = diffs[diff_id].to_lower();
	
	var diff = "" if diff_name == "normal" else "-" + diff_name;
	var song = songs[cur_song].to_lower();
	
	score = HighScore.get_score(song, diff);
	rank = HighScore.get_rank(song, diff);
	percent = HighScore.get_percent(song, diff);
	
	$scoreText.text = "SCORE: %s"%[int(cur_score)];
	$percentText.text = "PERCENT: %s"%[str(float(percent), "%")];
	$fcText.text = "RANK: %s"%[rank];
	$fcText.modulate = Color(1.0, 0.892, 0.0, 1.0) if rank == "SFC" else Color.WHITE;
	
	if GlobalOptions.low_quality:
		return;
		
	for i in songs.size():
		for letterID in song_stuff.get_child(i).get_child_count():
			song_stuff.get_child(i).get_children()[letterID].scale = lerp(song_stuff.get_child(i).get_children()[letterID].scale, Vector2(1.0, 1.0), 0.10);
			
	for i in songs.size():
		for letters in song_stuff.get_child(i).get_children():
			if songs[i] == "thorns":
				letters.offset = Vector2(randf_range(5, 7), randf_range(10, 30));
			else:
				letters.offset = Vector2.ZERO;
				
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && Global.can_use_menus:
			if ev.keycode in [Global.get_key("escape")] && !ev.echo:
				Global.cur_thing = 0;
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
			if ev.keycode in [Global.get_key("ui_down")] && !ev.echo && !noSpam:
				change_song(1);
				
			if ev.keycode in [Global.get_key("ui_up")] && !ev.echo && !noSpam:
				change_song(-1);
				
			if ev.keycode in [Global.get_key("ui_left")] && !noSpam && !ev.echo:
				changeDiff(-1);
				
			if ev.keycode in [Global.get_key("ui_right")] && !noSpam && !ev.echo:
				changeDiff(1);
				
			if SongData.chart_dont_exist && $warning.visible:
				if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo:
					$warning.visible = false;
					noSpam = false;
			else:
				if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo && !noSpam:
					noSpam = true;
					go_to_song(songs[cur_song], diffs[cur_diff if !cur_diff > diffs.size()-1 else 0]);
					
			if ev.keycode in [KEY_SPACE] && !ev.echo:
				var inst_shit = songs[cur_song].to_lower() if diffs[cur_diff] != "remix" else str(songs[cur_song].to_lower(),"-remix");
				MusicManager._play_song(inst_shit + "/Inst", true, true);
				
func beat_hit(beat):
	for i in songs.size():
		for letterID in song_stuff.get_child(i).get_child_count():
			if songs[i] == "test":
				if beat % 2 == 0 && letterID % 2 == 0:
					song_stuff.get_child(i).get_children()[letterID].scale = Vector2(1.5,1.5)
					
				elif beat % 2 != 0 && letterID % 2 != 0:
					song_stuff.get_child(i).get_children()[letterID].scale = Vector2(1.5,1.5)
					
func go_to_song(song, diff_path):
	SongData.loadJson(song, diff_path);
	
	if !SongData.chart_dont_exist:
		Sound.playAudio("confirmMenu", false);
		SongData.week_songs = song;
		SongData.week_diffs = diff_path;
		SongData.isStoryMode = false;
		SongData.weekName = cool_weeks[cur_song];
		MusicManager._stop_music();
		
		if !cur_song > cool_weeks.size()-1:
			SongData.week = cool_weeks[cur_song];
		else:
			SongData.week = "";
			
		await get_tree().create_timer(0.6).timeout;
		Global.changeScene("gameplay/PlayState", true, false);
	else:
		$warning.visible = true;
		
		var difficultyPath = "";
		if diff_path == "" or diff_path == "normal":
			difficultyPath = "res://assets/data/songs/%s/%s.json"%[song, song];
		else:
			difficultyPath = "res://assets/data/songs/%s/%s-%s.json"%[song, song, diff_path];
			
		$warning/Label.text = "Missing Chart:\n%s"%[difficultyPath];
		Sound.playAudio("cancelMenu", false);
		
func change_song(change):
	cur_song += change;
	
	Sound.playAudio("scrollMenu", false);
	cur_song = wrapi(cur_song, 0, len(songs));
	Global.cur_thing = cur_song;
	update_song();
	
func changeDiff(shit):
	cur_diff += shit;
	cur_diff = wrapi(cur_diff if diffs.size() > 1 else 0, 0, len(diffs));
	$difficultyText.text = str("< ",diffs[cur_diff].to_upper()," >");
	
func update_song():
	diffs = ["easy", "normal", "hard"] if week_difficulties[cur_song] == [] else week_difficulties[cur_song];
	if diffs == null or diffs == []:
		diffs = ["easy", "normal", "hard"];
		
	$difficultyText.text = str("< ",diffs[cur_diff if !cur_diff > diffs.size()-1 else 0].to_upper()," >");
	
	for j in songs.size():
		icons_stuff.get_child(j).modulate.a = 1 if j == cur_song else 0.5;
		song_stuff.get_child(j).modulate.a = 1 if j == cur_song else 0.5;
		

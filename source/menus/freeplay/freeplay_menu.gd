extends Node2D

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

var weekJson = {};

func _ready() -> void:
	Conductor.reset();
	Conductor.getSongTime = 0.0;
	
	Discord.update_discord_info("freeplay menu", "Is in menus");
	
	weeks = Global.get_folder("assets/data/weeks data/%s"%[SongData.week_folder_path]);
	
	for i in weeks:
		weekJson = Global.load_json("assets/data/weeks data/%s/%s"%[SongData.week_folder_path, i.replace(".json", "")])
		
		if weekJson == null:
			continue;
			
		if !weekJson.has("songs"):
			continue;
			
		if weekJson.get("hideFromFreeplay", false):
			continue;
			
		var week_name = weekJson.get("weekName", "");
		var week_diffs = weekJson.get("weekDifficulties", []);
		
		for song_data in weekJson["songs"]:
			if song_data.size() < 3:
				continue;
				
			add_song(song_data[0], song_data[1], song_data[2], week_name, week_diffs);
			
	var unlocked_songs = HighScore.unlockSongs.keys();
	unlocked_songs.sort();
	
	for song in unlocked_songs:
		var data = HighScore.unlockSongs[song];
		
		add_song(song, data.get("icon", ""), data.get("color", [1.0, 1.0, 1.0]), data.get("week name", ""), data.get("diffs", []));
		
	if songs.is_empty():
		return;
		
	song_stuff.position.y = 350.0 - coolOffset * cur_song;
	icons_stuff.position.y = 350.0 - coolOffset * cur_song;
	
	$bg.modulate = get_current_bg_color();
	
	var chance = randi_range(0, 1000) <= 2;
	for i in songs.size():
		song_stuff.get_child(i).wave = chance;
		song_stuff.get_child(i).rainbow = chance;
		
	change_song(Global.current_selected["freeplay"]);
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
	alphabet.waveIntensity = 10.0;
	alphabet.waveSpeed = 5.0;
	alphabet._creat_word(new_song);
	
	if new_song == "thorns":
		alphabet.shaking = true;
		alphabet.shakingX = 5.0;
		alphabet.shakingY = 8.0;
		
	alphabet.position.y += offSetShit;
	song_stuff.add_child(alphabet);
	
	var icon = freeplayIcon.new();
	icon.alphabet = alphabet;
	icon.new_x = 100;
	icon.load_icon(new_icon);
	icons_stuff.add_child(icon);
	
	offSetShit += coolOffset;
	
func _process(delta):
	if songs.is_empty():
		return;
		
	song_stuff.position.y = lerp(float(song_stuff.position.y), float(350-coolOffset*cur_song), 1.0 - exp(-12.0 * delta));
	icons_stuff.position.y = lerp(float(icons_stuff.position.y), float(350-coolOffset*cur_song), 1.0 - exp(-12.0 * delta));
	
	$bg.modulate = $bg.modulate.lerp(get_current_bg_color(), 1.0 - exp(-6.0 * delta));
	
	var diff_id = cur_diff if cur_diff <= diffs.size() - 1 else 0;
	var diff_name = diffs[diff_id].to_lower();
	
	var diff = "" if diff_name == "normal" else "-" + diff_name;
	var song = songs[cur_song].to_lower();
	
	score = HighScore.get_score(song, diff);
	rank = HighScore.get_rank(song, diff);
	percent = HighScore.get_percent(song, diff);
	
	cur_score = lerp(float(cur_score), float(score), 1.0 - exp(-12.0 * delta));
	
	$scoreText.text = "SCORE: %s\nRANK: %s\nACCURACY: %s" % [str(roundi(cur_score)), rank, str(float(percent), "%")];
	
func _input(ev):
	if !ev is InputEventKey:
		return;
		
	if !ev.pressed or ev.echo or !Global.can_use_menus:
		return;
		
	if ev.keycode == GlobalOptions.get_key("escape"):
		Global.changeScene("menus/main_menu/MainMenu", true, false)
		
	elif ev.keycode == GlobalOptions.get_key("ui_down"):
		if !noSpam:
			change_song(1);
			
	elif ev.keycode == GlobalOptions.get_key("ui_up"):
		if !noSpam:
			change_song(-1);
			
	elif ev.keycode == GlobalOptions.get_key("ui_left"):
		if !noSpam:
			changeDiff(-1);
			
	elif ev.keycode == GlobalOptions.get_key("ui_right"):
		if !noSpam:
			changeDiff(1);
			
	elif ev.keycode == GlobalOptions.get_key("enter") or ev.keycode == KEY_KP_ENTER:
		if SongData.chart_dont_exist && $warning.visible:
			$warning.visible = false;
			noSpam = false;
			
		elif !noSpam:
			noSpam = true;
			go_to_song(songs[cur_song], get_current_diff());
			
	elif ev.keycode == KEY_SPACE:
		var diff = get_current_diff();
		var suffix = "-remix" if diff == "remix" else "";
		
		MusicManager._play_song("/Inst%s"%[suffix], "songs/%s/song"%[songs[cur_song].to_lower()], true);
		
func go_to_song(song, diff_path):
	SongData.loadJson(song, diff_path);
	
	if !SongData.chart_dont_exist:
		Sound.playAudio("confirmMenu", false);
		
		SongData.week_songs = song;
		SongData.week_diffs = diff_path;
		SongData.isStoryMode = false;
		
		MusicManager._stop_music();
		
		SongData.weekName = cool_weeks[cur_song] if !cur_song > cool_weeks.size()-1 else "";
		SongData.week = cool_weeks[cur_song] if !cur_song > cool_weeks.size()-1 else "";
		
		await get_tree().create_timer(0.6).timeout;
		Global.changeScene("gameplay/PlayState", true, false);
	else:
		$warning.visible = true;
		
		var difficultyPath = ("res://assets/songs/%s/chart/%s.json"%[song, song]) if diff_path == "" or diff_path == "normal" else ("res://assets/songs/%s/chart/%s-%s.json"%[song, song, diff_path]);
		$warning/Label.text = "Missing Chart:\n%s"%[difficultyPath];
		Sound.playAudio("cancelMenu", false);
		
func change_song(change):
	if songs.is_empty():
		return;
		
	Sound.playAudio("scrollMenu", false);
	
	cur_song = wrapi(cur_song + change, 0, songs.size());
	
	Global.currentFreeplay = cur_song;
	
	update_song();
	
func changeDiff(change):
	if diffs.is_empty():
		diffs = ["easy", "normal", "hard"];
		
	cur_diff = wrapi(cur_diff + change, 0, diffs.size());
	
	$difficultyText.text = "< %s >"%[get_current_diff().to_upper()];
	
	update_score();
	
func update_song():
	if songs.is_empty():
		return
		
	diffs = week_difficulties[cur_song];
	
	if diffs.is_empty():
		diffs = ["easy", "normal", "hard"];
		
	cur_diff = wrapi(cur_diff, 0, diffs.size());
	
	$difficultyText.text = "< %s >"%[get_current_diff().to_upper()];
	
	for i in songs.size():
		var alpha = 1.0 if i == cur_song else 0.5;
		
		icons_stuff.get_child(i).modulate.a = alpha;
		song_stuff.get_child(i).modulate.a = alpha;
		
	update_score();
	
func update_score() -> void:
	if songs.is_empty():
		return;
		
	var song = songs[cur_song].to_lower();
	var diff = get_current_diff();
	var diff_path = "" if diff == "normal" else "-" + diff;
	
	score = HighScore.get_score(song, diff_path);
	rank = HighScore.get_rank(song, diff_path);
	percent = HighScore.get_percent(song, diff_path);
	
func get_current_bg_color():
	if bg_colors.is_empty():
		return Color.WHITE;
		
	var color_data = bg_colors[cur_song];
	
	if color_data is Color:
		return color_data;
		
	if color_data.size() >= 3:
		return Color(
			color_data[0],
			color_data[1],
			color_data[2]
		);
		
	return Color.WHITE;
	
func get_current_diff():
	if diffs.is_empty():
		return "normal";
		
	return diffs[wrapi(cur_diff, 0, diffs.size())];

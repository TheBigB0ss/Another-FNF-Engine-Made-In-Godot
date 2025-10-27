extends Node

var score_data = {};
var rank_data = {};
var unlockSongs = {};
var percent_data = {};
var week_status = {};

func _ready():
	#clear_data();
	load_score();
	update_version();
	
func save_score():
	var new_jsonFile = FileAccess.open("user://Score.json", FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(score_data, "\t"));
	
func save_rank():
	var new_RankFile = FileAccess.open("user://RankList.json", FileAccess.WRITE);
	new_RankFile.store_string(JSON.stringify(rank_data, "\t"));
	
func save_percent():
	var new_PercentFile = FileAccess.open("user://Songs Percent.json", FileAccess.WRITE);
	new_PercentFile.store_string(JSON.stringify(percent_data, "\t"));
	
func save_song():
	var new_jsonFile = FileAccess.open("user://UnlockedSongsList.json", FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(unlockSongs, "\t"));
	print(unlockSongs)
	
func save_week_status():
	var new_jsonFile = FileAccess.open("user://WeekStatus.json", FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(week_status, "\t"));
	
func load_score():
	if FileAccess.file_exists("user://WeekStatus.json"):
		var new_jsonFile = FileAccess.open("user://WeekStatus.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		week_status = jsonData.get_data();
		new_jsonFile.close();
	else:
		var new_jsonFile = FileAccess.open("user://WeekStatus.json", FileAccess.WRITE);
		new_jsonFile.store_string(JSON.stringify(week_status, "\t"));
		
	if FileAccess.file_exists("user://Score.json"):
		var new_jsonFile = FileAccess.open("user://Score.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		score_data = jsonData.get_data();
		new_jsonFile.close();
	else:
		var new_jsonFile = FileAccess.open("user://Score.json", FileAccess.WRITE);
		new_jsonFile.store_string(JSON.stringify(score_data, "\t"));
		
	if FileAccess.file_exists("user://RankList.json"):
		var new_jsonFile = FileAccess.open("user://RankList.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		rank_data = jsonData.get_data();
		new_jsonFile.close();
	else:
		var new_jsonFile = FileAccess.open("user://RankList.json", FileAccess.WRITE);
		new_jsonFile.store_string(JSON.stringify(rank_data, "\t"));
		
	if FileAccess.file_exists("user://Songs Percent.json"):
		var new_jsonFile = FileAccess.open("user://Songs Percent.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		percent_data = jsonData.get_data();
		new_jsonFile.close();
	else:
		var new_jsonFile = FileAccess.open("user://Songs Percent.json", FileAccess.WRITE);
		new_jsonFile.store_string(JSON.stringify(percent_data, "\t"));
		
	if FileAccess.file_exists("user://UnlockedSongsList.json"):
		var new_jsonFile = FileAccess.open("user://UnlockedSongsList.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		unlockSongs = jsonData.get_data();
		new_jsonFile.close();
		print(unlockSongs)
	else:
		var new_jsonFile = FileAccess.open("user://UnlockedSongsList.json", FileAccess.WRITE);
		new_jsonFile.store_string(JSON.stringify(unlockSongs, "\t"));
		
func get_song_score(song = "", diff = "", score = 0):
	if diff == "normal":
		score_data[set_song(song, "")] = score;
	else:
		score_data[set_song(song, diff)] = score;
		
	save_score();
	
func get_song_percent(song = "", diff = "", percent = 0.0):
	if diff == "normal":
		percent_data[set_song(song, "")] = percent;
	else:
		percent_data[set_song(song, diff)] = percent;
		
	save_percent();
	
func get_song_rank(song = "", diff = "", rank = ""):
	if diff == "normal":
		rank_data[set_song(song, "")] = str(rank);
	else:
		rank_data[set_song(song, diff)] = str(rank);
		
	save_rank();
	
func get_score(song = "", diff = ""):
	if !score_data.has(set_song(song, diff)):
		get_song_score(song, diff, 0);
		
	return int(score_data[set_song(song, diff)]);
	
func get_percent(song = "", diff = ""):
	if !percent_data.has(set_song(song, diff)):
		get_song_percent(song, diff, 0.0);
		
	return float(percent_data[set_song(song, diff)]);
	
func get_rank(song = "", diff = ""):
	if !rank_data.has(set_song(song, diff)):
		get_song_rank(song, diff, "???");
		
	return str(rank_data[set_song(song, diff)]);
	
func unlocksong(song, icon, color, diffs):
	unlockSongs[song] = {"icon": icon,  "color": color, "diffs": diffs};
	save_song();
	
func unlockweek(week, last_week, week_name, week_locked):
	if last_week != week_name && week_locked:
		return week_status[week] == true;
	else:
		return true;
		
func set_song(song, diff):
	return str(song, diff);
	
func update_version():
	score_data["version"] = 1;
	rank_data["version"] = 1;
	percent_data["version"] = 1;
	
	if !score_data.has("version") or score_data["version"] < 1:
		clearScore();
		
	if !rank_data.has("version") or rank_data["version"] < 1:
		clearRank();
		
	if !percent_data.has("version") or percent_data["version"] < 1:
		clearPercent();
		
func clear_data():
	clearRank();
	clearPercent();
	clearScore();
	save_song();
	clearWeekStatus();
	
func clearRank():
	rank_data = {};
	save_rank();
	
func clearPercent():
	percent_data = {};
	save_percent();
	
func clearScore():
	score_data = {};
	save_score();
	
func clearSongStatus():
	unlockSongs = {};
	save_song();
	
func clearWeekStatus():
	week_status = {};
	save_week_status();

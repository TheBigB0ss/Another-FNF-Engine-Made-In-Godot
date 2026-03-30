extends Node

var score_data = {};
var rank_data = {};
var unlockSongs = {};
var percent_data = {};
var week_status = {};

var files = {
	"Score": score_data,
	"RankList": rank_data,
	"SongsPercent": percent_data,
	"UnlockedSongsList": unlockSongs,
	"WeekStatus": week_status
};

func _ready():
	for i in files:
		files[i].merge(loadJson(i));
		
	update_version();
	
func saveJson(path, data):
	var new_jsonFile = FileAccess.open("user://%s.json"%[path], FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(data, "\t"));
	
func loadJson(path):
	if FileAccess.file_exists("user://%s.json"%[path]):
		var new_jsonFile = FileAccess.open("user://%s.json"%[path], FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		new_jsonFile.close();
		
		return jsonData.get_data();
	else:
		saveJson(path, {});
		return {};
		
func save_score(): saveJson("Score", score_data);
func save_rank(): saveJson("RankList", rank_data);
func save_percent(): saveJson("SongsPercent", percent_data);
func save_song(): saveJson("UnlockedSongsList", unlockSongs);
func save_week_status(): saveJson("WeekStatus", week_status);

func get_song_score(song = "", diff = "", score = 0): score_data[set_song(song, diff)] = score; save_score();
func get_song_percent(song = "", diff = "", percent = 0.0): percent_data[set_song(song, diff)] = percent; save_percent();
func get_song_rank(song = "", diff = "", rank = ""): rank_data[set_song(song, diff)] = str(rank); save_rank();
func get_score(song = "", diff = ""): return int(score_data.get(set_song(song, diff), 0));
func get_percent(song = "", diff = ""): return float(percent_data.get(set_song(song, diff), 0.0));
func get_rank(song = "", diff = ""): return str(rank_data.get(set_song(song, diff), "???"));

func unlocksong(song, icon, color, weekName, diffs): unlockSongs[song] = {"icon": icon,  "color": color, "week name": weekName, "diffs": diffs}; save_song();

func unlockweek(week, last_week, week_name, week_locked): 
	if last_week != week_name && week_locked: 
		return week_status[week] == true; 
	else:
		return true;
		
func set_song(song, diff):
	return str(song, diff);
	
func update_version():
	var version = 1;
	
	if score_data.get("version", 0) != version:
		clearScore();
	if rank_data.get("version", 0) != version:
		clearRank();
	if percent_data.get("version", 0) != version:
		clearPercent();
		
	score_data["version"] = version;
	rank_data["version"] = version;
	percent_data["version"] = version;
	
func clear_data(): clearRank(); clearPercent(); clearScore(); save_song(); clearWeekStatus(); clearSongStatus();
func clearRank(): rank_data = {}; save_rank();
func clearPercent(): percent_data = {}; save_percent();
func clearScore(): score_data = {}; save_score();
func clearSongStatus(): unlockSongs = {}; save_song();
func clearWeekStatus(): week_status = {}; save_week_status();

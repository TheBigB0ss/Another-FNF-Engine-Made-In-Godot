class_name CodenameChart extends Node

static func apply(song_chart, song_name):
	SongData.playerNotes.clear();
	SongData.opponentNotes.clear();
	SongData.songSections.clear();
	
	var meta_data = load_metadata(song_chart, song_name);
	
	SongData.stage = meta_data.get("stage", "stage");
	SongData.song = meta_data.get("name", meta_data.get("displayName", song_name)).replace("-remix", "");
	
	SongData.songBpm = meta_data.get("bpm", 100.0);
	SongData.songSpeed = song_chart.get("scrollSpeed", meta_data.get("scrollSpeed", 1.0));
	
	convert_sections(song_chart);
	
static func load_metadata(song_chart, song_name):
	var meta_path = "res://assets/songs/%s/chart/meta.json"%[song_name];
	
	if FileAccess.file_exists(meta_path):
		var file = FileAccess.open(meta_path, FileAccess.READ);
		var json = JSON.new();
		var error = json.parse(file.get_as_text());
		file.close();
		
		if error == OK:
			return json.data;
			
	return song_chart.get("meta", {});
	
static func convert_sections(song_chart):
	var lastMustHit = false;
	var lastSection = 0;
	for strum in song_chart.get("strumLines", []):
		for note in strum.get("notes", []):
			lastSection = max(lastSection, Conductor.get_section(note["time"]));
			
	for i in lastSection + 1:
		SongData.songSections.append({
			"lengthInSteps": 16,
			"changeBPM": false,
			"bpm": SongData.songBpm,
			"mustHitSection": lastMustHit,
			"gfSection": false,
			"altAnim": false,
			"sectionNotes": []
		});
		
		lastMustHit = !lastMustHit;
		
static func convert_codenameChart(song_chart, events_path):
	load_events(events_path);
	
	for strum in song_chart.get("strumLines", []):
		var character = strum.get("characters", [])[0] if not strum.get("characters", []).is_empty() else "";
		
		match strum.get("position", ""):
			"boyfriend":
				SongData.player1 = character;
			"dad":
				SongData.player2 = character;
			"girlfriend":
				SongData.gfPlayer = character;
				
		if !(strum.get("position", "") in ["boyfriend", "dad", "girlfriend"]):
			continue;
			
		for i in strum.get("notes", []):
			var note = [
				i.get("time", 0),
				i.get("id", 0),
				i.get("sLen", 0),
				song_chart["noteTypes"][i["type"]-1] if i["type"] > 0 else "",
				null,
				null
			];
			
			if strum.get("position", "") == "boyfriend":
				SongData.playerNotes.append(note);
			else:
				SongData.opponentNotes.append(note);
				
static func load_events(events_path):
	if events_path.is_empty():
		return;
		
	if !FileAccess.file_exists(events_path):
		return;
		
	var file = FileAccess.open(events_path, FileAccess.READ);
	var json = JSON.new();
	var error = json.parse(file.get_as_text());
	file.close();
	
	if error != OK:
		return;
		
	SongData.eventsData = json.data;
	SongData.songEvents = json.data.get("song", {}).get("events", []);
	

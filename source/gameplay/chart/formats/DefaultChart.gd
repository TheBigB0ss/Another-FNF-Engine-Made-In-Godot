class_name DefaultChart extends Node

static func apply(song_chart, events_path = ""):
	SongData.playerNotes.clear();
	SongData.opponentNotes.clear();
	SongData.songSections.clear();
	
	var meta = song_chart.get("meta", {});
	
	SongData.stage = meta.get("stage", "stage");
	SongData.song = meta.get("song", "bopeebo").replace("-remix", "");
	
	SongData.isPixelStage = meta.get("isPixelStage", false);
	SongData.needVoice = meta.get("needsVoices", false);
	
	SongData.songBpm = meta.get("bpm", 100.0);
	SongData.songSpeed = meta.get("speed", 1.0);
	
	SongData.player1 = meta.get("player1", "bf");
	SongData.player2 = meta.get("player2", "dad");
	SongData.gfPlayer = meta.get("gfVersion", "gf");
	
	for strum in song_chart.get("strums", []):
		for note_data in strum.get("player", []):
			SongData.playerNotes.append(_convert_note(note_data));
			
		for note_data in strum.get("opponent", []):
			SongData.opponentNotes.append(_convert_note(note_data));
			
	for section in song_chart.get("sections", []):
		SongData.songSections.append(section);
		
	load_events(song_chart, events_path)
	
static func _convert_note(note_data: Array) -> Array:
	return [
		note_data[0] if note_data.size() > 0 else 0,
		note_data[1] if note_data.size() > 1 else 0,
		note_data[2] if note_data.size() > 2 else 0,
		note_data[3] if note_data.size() > 3 else "",
		note_data[4] if note_data.size() > 4 else null,
		note_data[5] if note_data.size() > 5 else null
	]
	
static func load_events(song_chart, events_path):
	if !song_chart.get("events", []).is_empty():
		SongData.songEvents = song_chart.get("events", []);
		return;
		
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
	

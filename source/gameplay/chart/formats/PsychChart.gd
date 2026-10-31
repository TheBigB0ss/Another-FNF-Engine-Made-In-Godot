class_name PsychChart extends Node

static func apply(song_data):
	var song_info = song_data["song"];
	
	SongData.stage = song_info.get("stage", "stage");
	SongData.song = song_info["song"].replace("-remix", "");
	SongData.isPixelStage = song_info.get("isPixelStage", false);
	SongData.needVoice = song_info.get("needsVoices", false);
	
	SongData.songBpm = song_info["bpm"];
	SongData.songSpeed = song_info["speed"];
	
	SongData.player1 = song_info["player1"];
	SongData.player2 = song_info["player2"];
	SongData.gfPlayer = song_info["gfVersion"];
	
static func convert_pyschChart(song_data, events_path):
	var song_info = song_data["song"];
	
	SongData.playerNotes.clear();
	SongData.opponentNotes.clear();
	SongData.songSections.clear();
	
	for section in song_info.get("notes", []):
		SongData.songSections.append({
			"lengthInSteps": section.get("lengthInSteps", 16),
			"altAnim": section.get("altAnim", false),
			"bpm": section.get("bpm", song_info.get("bpm", 100.0)),
			"changeBPM": section.get("changeBPM", false),
			"mustHitSection": section.get("mustHitSection", true),
			"gfSection": section.get("gfSection", false)
		});
		
		var must_hit = section.get("mustHitSection", true);
		
		for i in section.get("sectionNotes", []):
			var lane = int(i[1]);
			
			if lane < 0 or lane >= 8:
				continue;
				
			var note = [
				i[0],
				int(i[1])%4,
				i[2],
				i[3] if i.size() > 3 else "",
				i[4] if i.size() > 4 else null,
				i[5] if i.size() > 4 else null
			];
			
			if lane < 4:
				if must_hit:
					SongData.playerNotes.append(note);
				else:
					SongData.opponentNotes.append(note);
			else:
				if must_hit:
					SongData.opponentNotes.append(note);
				else:
					SongData.playerNotes.append(note);
					
	if !song_info.get("events", []).is_empty():
		SongData.songEvents = song_info.get("events", []);
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

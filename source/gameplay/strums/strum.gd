#I took the inspiration of this code from Rubicon Engine, created by legole0 (https://x.com/legole0)

class_name ExtraStrum extends Node2D

var notes = ["left", "down", "up", "right"];
var strumArray = [];
@export var noteOffset = 105;
@export var strumScale = Vector2(1,1);
@export var note_data = {
	"Texture Folder": "default",
	"Note Texture": "notes",
	"Strum Texture": "StrumlineNotes",
	"Note Line Texture": "NOTE_hold_assets"
};

@export_file_path("*.json") var chart_path = "";
@export var strum_char:Node2D:
	set(value):
		if value is Character or value is AtlasCharacter or value is SparrowCharacter:
			strum_char = value;
			
@export var enable = false;

var strumNode = null;
var noteNode = null;

var chart = {}
var notesList = [];
var array_notes = [];
var songNotes = [];

signal pressed_note(char);

func _ready() -> void:
	strumNode = Node2D.new();
	add_child(strumNode);
	
	noteNode = Node2D.new();
	add_child(noteNode);
	
	for i in notes.size():
		var strumNote = Note.new();
		strumNote.modulate.a = 1;
		strumNote.position.x = i * noteOffset;
		strumNote.isStrumNote = true;
		
		if !SongData.isPixelStage:
			strumNote.note_type = note_data["Texture Folder"];
			strumNote.note_skin = note_data["Note Texture"];
			strumNote.note_strum = note_data["Strum Texture"];
			strumNote.note_lines = note_data["Note Line Texture"];
			
		strumNote.noteData = i;
		
		strumNode.add_child(strumNote);
		strumArray.append(strumNote);
		
		strumNote.strumNote.play(notes[i] + " static");
		
	for i in strumNode.get_children():
		i.scale = strumScale;
		
	notesAppears();
	
	var file = FileAccess.open(chart_path, FileAccess.READ);
	var json = JSON.new();
	
	json.parse(file.get_as_text());
	chart = json.data;
	
	if chart.has("song"):
		for section in chart["song"]["notes"]:
			for note in section["sectionNotes"]:
				songNotes.append([note[0], int(note[1]) % 4, note[2], note[3] if note.size() > 3 else "", note[4] if note.size() > 4 else null, note[5] if note.size() > 5 else null]);
				
	elif chart.has("codenameChart"):
		var types = chart["noteTypes"];
		
		for strum in chart["strumLines"]:
			for note in strum["notes"]:
				songNotes.append([note["time"], note["id"], note["sLen"], types[note["type"] - 1] if note["type"] > 0 else "", null, null]);
	else:
		for note in chart["strums"][0]["opponent"]:
			songNotes.append(note);
			
	for note in songNotes:
		array_notes.append([note[0], note[1], note[2], note[3], note[4], note[5]]);
		
	array_notes.sort_custom(func(a, b): return a[0] < b[0])
	
func notesAppears():
	for i in strumNode.get_child_count():
		var strumNote = strumNode.get_child(i);
		strumNote.modulate.a = 0.0;
		
		var tw = get_tree().create_tween();
		tw.tween_property(strumNote, "modulate:a", 1.0, 1.0).set_delay(0.5 + (0.2 * i)).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT);
		
var spawnId = 0;
var notes_to_delete = [];
func _process(delta):
	if !enable:
		return;
		
	var distance_offset = 4000 if GlobalOptions.down_scroll else 2200;
	while spawnId < array_notes.size():
		var distance = (array_notes[spawnId][0] - Conductor.getSongTime)*Conductor.songSpeed;
		
		if distance > distance_offset:
			break;
			
		spawnNote(array_notes[spawnId][0], array_notes[spawnId][1], array_notes[spawnId][2], array_notes[spawnId][3], array_notes[spawnId][4], array_notes[spawnId][5]);
		
		spawnId += 1;
		
	for note in notesList:
		if note == null:
			continue
			
		var strum = strumArray[note.noteData];
		var strum_pos = strum.position;
		var strumY = strum_pos.y;
		
		note.position.x = strum_pos.x;
		note.rotation = strum.rotation;
		note.modulate.a = strum.modulate.a;
		note.scale = strum.scale;
		
		if !note.is_pressing or note.missedLongNote or note.missed:
			note.position.y = strumY + (Conductor.getSongTime - note.strumTime) * (0.45 * Conductor.songSpeed) if GlobalOptions.down_scroll else strumY - (Conductor.getSongTime - note.strumTime) * (0.45 * Conductor.songSpeed);
		else:
			note.position.y = strumY;
			
		if note.isPlayer:
			continue;
			
		if Conductor.seekTime >= 0 && note.strumTime < Conductor.seekTime:
			notes_to_delete.append(note);
			continue;
			
		if note.sustainLength <= 0:
			if Conductor.getSongTime > note.strumTime + 320:
				notes_to_delete.append(note);
		else:
			if !note.is_pressing && Conductor.getSongTime > note.strumTime + note.ogSustain + 335:
				notes_to_delete.append(note);
				
		if note.is_a_bad_note or note.ignoreNote:
			continue;
			
		if Conductor.getSongTime >= note.strumTime && notesList.size() > 0:
			note.opponent_pressed(strum_char);
			play_strum_anim(note, 0.40);
			self.emit_signal("pressed_note", strum_char);
			
			if note.manyHits > 0:
				continue;
				
			if note.sustainLength == 0:
				notesList.erase(note);
			else:
				if note.note != null:
					note.note.queue_free();
					
				note.is_pressing = true;
				if note.sustainLength <= 0:
					note.is_pressing = false;
					notesList.erase(note);
					
	notesList = notesList.filter(func(note): return note != null);
	
	for i in 4:
		var notes = strumArray[i];
		if notes.reset_arrow_anim > 0:
			notes.reset_arrow_anim = max(notes.reset_arrow_anim - 4 * delta, 0);
		elif notes.reset_arrow_anim <= 0:
			notes.play_note_anim("static");
			
	for i in notes_to_delete:
		notesList.erase(i);
		if i == null:
			continue;
			
		i.queue_free();
		
func sort_notes(a, b):
	if a != null && b != null:
		return a.strumTime < b.strumTime;
		
func spawnNote(strumTime, noteData, lenght, type, value1 = null, value2 = null):
	var note_data = int(noteData)%4;
	
	var note = Note.new();
	note.strumTime = strumTime;
	note.noteData = note_data;
	note.sustainLength = lenght;
	note.type = type;
	note.isGfNote = (type == "gf sing");
	note.is_altAnim = (type == "alt anim");
	note.no_anim = (type == "No Animation");
	note.is_hey_note = (type == "Hey!");
	note.must_press = note.isPlayer;
	note.secondary_opponent_note = true;
	
	if value1 != null && value2 != null && note.type == "Echo Note":
		note.manyHits = value1;
		note.amount = value2;
		
	note.emit_signal("noteCreated", note);
	
	var strum = strumArray[note.noteData];
	note.scale = strum.scale;
	note.rotation = strum.rotation;
	note.modulate.a = strum.modulate.a;
	note.strum_positions.y = strumNode.position.y + strum.position.y;
	note.position.x = strumNode.position.x + strum.position.x;
	
	if note.note:
		note.note.offset = strum.note.offset;
		
	notesList.append(note);
	notesList.sort_custom(Callable(self, "sort_notes"));
	
	noteNode.add_child(note);
	
func play_strum_anim(note = null, timer = 0.0):
	strumNode.get_child(note.noteData).reset_arrow_anim = timer;
	strumNode.get_child(note.noteData).play_note_anim("confirm");

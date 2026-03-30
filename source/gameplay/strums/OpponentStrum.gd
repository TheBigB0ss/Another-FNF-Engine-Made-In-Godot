extends Node2D

var notes = ["left", "down", "up", "right"];
var strumArray = [];
var offSetShit = 0;
@export var is_secondary_strum = false;
@export var noteOffset = 105;
@export var note_data: Dictionary = {
	"Texture Folder": "default",
	"Note Texture": "notes",
	"Strum Texture": "strumLineNotes",
	"Note Line Texture": "NOTE_hold_assets"
};
@export var strumScale = Vector2(1,1);
var strumNode = null;
var noteNode = null;

var chart = {};
var notesList = [];
var array_notes = [];
var opponentNotes = [];
var opponents_strums = [];
var new_opponentNotes = [];

var appearNOW = false;

func _ready() -> void:
	strumNode = Node2D.new();
	add_child(strumNode);
	
	noteNode = Node2D.new();
	add_child(noteNode);
	
	for i in notes.size():
		var strumNote = Note.new();
		strumNote.modulate.a = 0.0;
		strumNote.position.x = offSetShit;
		strumNote.isStrumNote = true;
		if !SongData.isPixelStage:
			strumNote.note_type = note_data["Texture Folder"];
			strumNote.note_skin = note_data["Note Texture"];
			strumNote.note_strum = note_data["Strum Texture"];
			strumNote.note_lines = note_data["Note Line Texture"];
			
		strumNote.noteData = i;
		strumNode.add_child(strumNote);
		offSetShit += noteOffset;
		
		strumArray.append(strumNote.strumNote);
		strumArray[i].play(notes[i]+" static");
		
	for i in strumArray.size():
		var cool_scale = strumScale;
		if SongData.isPixelStage:
			cool_scale = Vector2(9,9) if !is_secondary_strum else Vector2(4,4);
		strumArray[i].scale = cool_scale;
		
	var note_appers_now = get_tree().current_scene.get("skipIntro");
	if !note_appers_now:
		notesAppears();
		
	if note_appers_now:
		for i in strumNode.get_children():
			i.modulate.a = 1;
			
	for i in SongData.songNotes:
		for j in i["sectionNotes"]:
			array_notes.insert(0, [j[0], j[1], j[2], j[3], i["gfSection"], i["altAnim"], i["mustHitSection"], false]);
			
func _process(delta):
	for i in array_notes:
		var data = int(i[1])%(8 if !SongData.haveTwoOpponents else 12);
		var distance = (i[0] - Conductor.getSongTime)*Conductor.songSpeed;
		if GlobalOptions.down_scroll:
			distance = -distance;
		if distance <= 2150 && !i[7]:
			spawnNote(i[0], data, i[2], i[3], i[4], i[5], i[6]);
			i[7] = true;
			
	for note in notesList:
		if note == null:
			continue
			
		var strum = strumNode.get_child(note.noteData);
		var strum_pos = strum.position;
		var strumY = strum_pos.y;
		
		note.position.x = strum_pos.x;
		note.rotation = strum.rotation;
		note.modulate.a = strum.modulate.a;
		
		if !note.is_pressing or note.MissedlongNote or note.missed:
			note.position.y = strumY + (Conductor.getSongTime - note.strumTime) * (0.45 * Conductor.songSpeed) if GlobalOptions.down_scroll else strumY - (Conductor.getSongTime - note.strumTime) * (0.45 * Conductor.songSpeed);
		else:
			note.position.y = strumY;
			
	opponents_strums = [opponentNotes] if !SongData.haveTwoOpponents else [opponentNotes, new_opponentNotes];
	
	for strums in opponents_strums:
		for note in strums:
			if note == null or note.isPlayer or note.is_a_bad_note:
				continue;
				
			if Conductor.getSongTime >= note.strumTime:
				note.opponent_pressed();
				if note.sustainLength == 0:
					strums.erase(note);
					notesList.erase(note);
				else:
					if note.note != null:
						note.note.queue_free();
						
					note.is_pressing = true;
					if note.sustainLength <= 0:
						note.is_pressing = false;
						strums.erase(note);
						notesList.erase(note);
						
	opponents_strums = opponents_strums.filter(func(note): return note != null);
	notesList = notesList.filter(func(note): return note != null);
	
	for notes in strumNode.get_children():
		if notes.reset_arrow_anim > 0:
			notes.reset_arrow_anim = max(notes.reset_arrow_anim - 4 * delta, 0);
			
		if notes.reset_arrow_anim <= 0:
			notes.play_note_anim("static");
			
func notesAppears():
	var tw = get_tree().create_tween();
	for i in strumNode.get_child_count():
		var strumNote = strumNode.get_child(i);
		tw.tween_property(strumNote, "modulate:a", 1, 0.25+(0.1*i)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		
func spawnNote(strumTime, noteData, lenght, type, isGfNote, isAltAnim, isPlayer):
	var data = int(noteData)%4;
	var is_a_player_note = isPlayer;
	var is_second_opponent = false;
	
	if noteData > 3 && noteData < 8:
		is_a_player_note = !isPlayer;
		
	if noteData >= 8 && SongData.haveTwoOpponents:
		isPlayer = false;
		is_a_player_note = false;
		is_second_opponent = true;
		
	if is_a_player_note:
		return;
		
	if is_secondary_strum && !is_second_opponent:
		return;
		
	if !is_secondary_strum && is_second_opponent:
		return;
		
	var note = Note.new();
	note.is_altAnim = isAltAnim;
	note.strumTime = strumTime;
	note.noteData = data;
	note.sustainLength = lenght;
	note.type = type;
	note.isGfNote = isGfNote or (type == "gf sing");
	note.is_altAnim = isAltAnim or (type == "alt anim");
	note.no_anim = (type == "No Animation");
	note.is_hey_note = (type == "Hey!");
	note.must_press = note.isPlayer;
	note.secondOpponentNote = is_second_opponent;
	note.isSustain = note.sustainLength > 0.0;
	note.visible = !GlobalOptions.middle_scroll;
	
	note.rotation = strumNode.get_child(note.noteData).rotation;
	note.modulate.a = strumNode.get_child(note.noteData).modulate.a;
	note.strum_positions.y = strumNode.position.y + strumNode.get_child(note.noteData).position.y;
	note.position.x = strumNode.position.x + strumNode.get_child(note.noteData).position.x;
	if note.note != null:
		note.note.offset = strumNode.get_child(note.noteData).note.offset;
		
	if is_second_opponent:
		new_opponentNotes.append(note);
	else:
		opponentNotes.append(note);
		
	notesList.append(note);
	notesList.sort_custom(Callable(self, "sort_notes"));
	
	noteNode.add_child(note);
	
func sort_notes(a, b):
	return a.strumTime < b.strumTime;
	

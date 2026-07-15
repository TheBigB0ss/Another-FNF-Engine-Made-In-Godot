extends Node2D

@onready var main_scene = get_tree().current_scene;
var notes = ["left", "down", "up", "right"];
var strumArray = [];
var offSetShit = 0;
var coolOffset = 105;
var can_miss = false;
@export var note_data: Dictionary = {
	"Texture Folder": "default",
	"Note Texture": "notes",
	"Strum Texture": "strumLineNotes",
	"Note Line Texture": "NOTE_hold_assets"
};
var strumNode = null;
var noteNode = null;

var notesList = [];
var array_notes = [];
var playerNotes = [];
var notes_to_delete = [];

var appearNOW = false;

func _ready() -> void:
	appearNOW = main_scene.skipIntro;
	
	strumNode = Node2D.new();
	add_child(strumNode);
	
	noteNode = Node2D.new();
	add_child(noteNode);
	
	for i in notes.size():
		var strumNote = Note.new();
		strumNote.modulate.a = 0.0;
		strumNote.position.x = offSetShit;
		strumNote.strumPressed = false;
		strumNote.isStrumNote = true;
		if !SongData.isPixelStage:
			strumNote.note_type = note_data["Texture Folder"];
			strumNote.note_skin = note_data["Note Texture"];
			strumNote.note_strum = note_data["Strum Texture"];
			strumNote.note_lines = note_data["Note Line Texture"];
			
		strumNote.noteData = i;
		strumNode.add_child(strumNote);
		offSetShit += coolOffset;
		
		strumArray.append(strumNote.strumNote);
		strumArray[i].play(notes[i]+" static");
		
	var note_appers_now = get_tree().current_scene.get("skipIntro");
	if !note_appers_now:
		notesAppears();
		
	if note_appers_now:
		for i in strumNode.get_children():
			i.modulate.a = 1;
			
	for i in SongData.playerNotes:
		var noteData = [i[0], i[1], i[2], i[3], i[4], i[5], false];
		array_notes.insert(0, noteData);
		
	array_notes.sort_custom(func(a,b): return a[0]<b[0]);
	
func _process(delta):
	for i in array_notes:
		var distance = (i[0] - Conductor.getSongTime)*Conductor.songSpeed;
		var distance_offset = 4000 if GlobalOptions.down_scroll else 2200;
		
		if distance <= distance_offset && !i[6]:
			spawnNote(i[0], i[1], i[2], i[3], i[4], i[5]);
			array_notes.erase(i);
		else:
			break;
			
	for note in notesList:
		if note == null:
			continue
			
		var strum = strumNode.get_child(note.noteData);
		var strum_pos = strum.position;
		var strumY = strum_pos.y;
		
		note.position.x = strum_pos.x;
		note.rotation = strum.rotation;
		note.modulate.a = strum.modulate.a;
		
		if !note.is_pressing:
			note.position.y = strumY + (Conductor.getSongTime - note.strumTime) * (0.45 * Conductor.songSpeed) if GlobalOptions.down_scroll else strumY - (Conductor.getSongTime - note.strumTime) * (0.45 * Conductor.songSpeed);
		else:
			note.position.y = strumY;
			
		if note.missedLongNote or note.missTimer > 0:
			var releaseDiff = (Conductor.getSongTime - note.release_time);
			note.position.y = strumY + releaseDiff * 0.45 * Conductor.songSpeed if GlobalOptions.down_scroll else strumY - releaseDiff * 0.45 * Conductor.songSpeed;
			
		if !note.isPlayer:
			continue;
			
		if Conductor.seekTime >= 0 && note.strumTime < Conductor.seekTime:
			notes_to_delete.append(note);
			continue;
			
		if Conductor.getSongTime > 155 + note.strumTime && !note.is_pressing && !note.is_a_bad_note && !note.ignoreNote:
			note.missed = true;
			note.miss_note();
			
		if Conductor.getSongTime > 320 + note.strumTime && !note.isSustain && (note.missed or note.ignoreNote):
			notes_to_delete.append(note);
			
		if Conductor.getSongTime > 335 + (note.strumTime+note.ogSustain) && note.isSustain && !note.is_pressing && (note.missed or note.ignoreNote):
			notes_to_delete.append(note);
			
	playerNotes = playerNotes.filter(func(note): return note != null);
	notesList = notesList.filter(func(note): return note != null);
	
	if GlobalOptions.isUsingBot:
		botInput();
	else:
		playerInput();
		
	var key_id = 0;
	for notes in strumNode.get_children():
		if notes.reset_arrow_anim > 0 && GlobalOptions.isUsingBot:
			notes.reset_arrow_anim = max(notes.reset_arrow_anim - 4 * delta, 0);
			
		if notes.reset_arrow_anim <= 0 && GlobalOptions.isUsingBot:
			notes.play_note_anim("static");
			
		if key_id > strumNode.get_child_count():
			break;
			
		var note = strumNode.get_child(key_id);
		var key = "ui_%s"%GlobalOptions.keys[GlobalOptions.keys_list[key_id]][1];
		press_note(key, note);
		
		key_id += 1;
		
	for i in notes_to_delete:
		playerNotes.erase(i);
		notesList.erase(i);
		if i == null:
			continue;
			
		i.queue_free();
		
func notesAppears():
	for i in strumNode.get_child_count():
		var strumNote = strumNode.get_child(i);
		strumNote.modulate.a = 0.0;
		
		var tw = get_tree().create_tween();
		tw.tween_property(strumNote, "modulate:a", 1.0, 1.0).set_delay(0.5 + (0.2 * i)).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT);
		
func playerInput():
	for note in notesList:
		if note == null or note.missed or !note.isPlayer:
			continue;
			
		var key = "ui_" + note.custom_note_dir;
		if note.can_press && playerNotes.size() > 0 && note.must_press:
			if Input.is_action_just_pressed(key):
				delete_note(note.custom_note_dir);
				
			if note.sustainLength <= 0 or !note.isSustain:
				continue;
				
			if Input.is_action_pressed(key) && note.missedLongNote && !note.missed && note.missTimer <= 0:
				if note.sustainLength <= 0:
					note.is_pressing = false;
					notes_to_delete.append(note);
				else:
					note.is_pressing = true;
					note.missTimer = 0.0;
					
		if !note.is_pressing:
			continue;
			
		if !Input.is_action_pressed(key):
			note.missedLongNote = true;
			note.release_time = Conductor.getSongTime;
		else:
			if note.missTimer <= 0.13 && note.missedLongNote:
				strumNode.get_child(int(note.noteData)).tap = false;
				note.release_time = 0.0;
				note.is_pressing = true;
				note.missedLongNote = false;
				note.missed = false;
				note.missTimer = 0.0;
				
func botInput():
	for note in notesList:
		if note == null or note.missed or !note.isPlayer:
			continue;
			
		if Conductor.getSongTime >= note.strumTime && note.can_press && playerNotes.size() > 0 && note.must_press && !note.is_a_bad_note:
			delete_note(note.custom_note_dir);
			
			if note.manyHits > 0:
				continue;
				
			if note.sustainLength == 0:
				notes_to_delete.append(note);
			else:
				if !note.is_pressing:
					continue;
					
				if note.sustainLength <= 0:
					note.is_pressing = false;
					notes_to_delete.append(note);
				else:
					note.is_pressing = true;
					note.missTimer = 0.0;
					
func press_note(key_to_press, ass_note):
	if Input.is_action_just_pressed(key_to_press) && !GlobalOptions.isUsingBot && SongData.is_not_in_cutscene:
		if !ass_note.strumPressed:
			ass_note.play_note_anim("press");
			
			if ass_note.tap:
				ass_note.curNoteAnim = ass_note.NOTES_ANIM[ass_note.noteData];
				get_tree().current_scene.call("playBfMissAnim", ass_note);
				GlobalOptions.emit_signal("ghost_tapping_miss", ass_note);
				
	if !Input.is_action_pressed(key_to_press) && !GlobalOptions.isUsingBot:
		ass_note.strumPressed = false;
		ass_note.play_note_anim("static");
		ass_note.tap = !GlobalOptions.ghost_tapping;
		
func spawnNote(strumTime, noteData, lenght, type, value1 = null, value2 = null):
	var data = int(noteData)%4;
	
	var note = Note.new();
	note.strumTime = strumTime;
	note.noteData = data;
	note.sustainLength = lenght;
	note.type = type;
	note.isGfNote = (type == "gf sing");
	note.is_altAnim = (type == "alt anim");
	note.no_anim = (type == "No Animation");
	note.is_hey_note = (type == "Hey!");
	note.isPlayer = true;
	note.must_press = note.isPlayer;
	
	if value1 != null && value2 != null && note.type == "Echo Note":
		note.manyHits = value1;
		note.amount = value2;
		
	note.notePressed.connect(main_scene.pressedNote);
	note.noteMissed.connect(main_scene.miss_note);
	note.longNoteMissed.connect(main_scene.miss_note);
	note.noteCreated.connect(main_scene.noteCreated);
	note.emit_signal("noteCreated", note);
	
	note.rotation = strumNode.get_child(note.noteData).rotation;
	note.modulate.a = strumNode.get_child(note.noteData).modulate.a;
	note.strum_positions.y = strumNode.position.y + strumNode.get_child(note.noteData).position.y;
	note.position.x = strumNode.position.x + strumNode.get_child(note.noteData).position.x;
	
	if note.note != null:
		note.note.offset = strumNode.get_child(note.noteData).note.offset;
		
	playerNotes.append(note);
	notesList.append(note);
	notesList.sort_custom(Callable(self, "sort_notes"));
	
	noteNode.add_child(note);
	
func delete_note(note_direction):
	var new_strumTime = INF;
	var new_note = null;
	
	playerNotes.sort_custom(Callable(self, "sort_notes"));
	notesList.sort_custom(Callable(self, "sort_notes"));
	
	notes_to_delete = notes_to_delete.filter(func(note): return note != null);
	
	for note in playerNotes:
		if note == null:
			continue;
			
		if note.custom_note_dir != note_direction:
			continue;
			
		var distance = (note.strumTime - Conductor.getSongTime);
		if distance <= new_strumTime && note.can_press:
			new_strumTime = distance;
			new_note = note;
			
			new_note.pressed();
			
			if note.manyHits > 0:
				return;
				
			if !note.isSustain:
				if new_note.is_a_bad_note:
					new_note.miss_note();
					
				new_note.queue_free();
				notes_to_delete.append(note);
			else:
				if new_note.note != null:
					new_note.note.queue_free();
					
				new_note.is_pressing = true;
				
func sort_notes(a, b):
	if a != null && b != null:
		return a.strumTime < b.strumTime;

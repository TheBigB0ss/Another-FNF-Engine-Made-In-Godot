#I took the inspiration of this code from Rubicon Engine, created by legole0 (https://x.com/legole0)

class_name ExtraStrum extends Node2D

var notes = ["left", "down", "up", "right"];
var strumArray = [];
var offSetShit = 0;
@export var noteOffset = 105;
@export var strumScale = Vector2(1,1);
@export var note_settings = {
	"Texture Folder": "default",
	"Note Texture": "notes",
	"Strum Texture": "StrumlineNotes",
	"Note Line Texture": "NOTE_hold_assets"
};
@export_file_path("*.json") var chart_path = "";
@export var enable = false;
@onready var main_scene = get_tree().current_scene;
@export var strum_char = Node2D;

var strumNode = null;
var noteNode = null;

var chart = {}
var notesList = [];
var array_notes = [];

signal pressed_note(char);

func _ready() -> void:
	strumNode = Node2D.new();
	add_child(strumNode);
	
	noteNode = Node2D.new();
	add_child(noteNode);
	
	for i in notes.size():
		var strumNote = Note.new();
		strumNote.modulate.a = 1;
		strumNote.position.x = offSetShit;
		strumNote.strumPressed = false;
		strumNote.isStrumNote = true;
		if !SongData.isPixelStage:
			strumNote.note_type = note_settings["Texture Folder"];
			strumNote.note_skin = note_settings["Note Texture"];
			strumNote.note_strum = note_settings["Strum Texture"];
			strumNote.note_lines = note_settings["Note Line Texture"];
			
		strumNote.noteData = i;
		strumNode.add_child(strumNote);
		offSetShit += noteOffset;
		
		strumArray.append(strumNote.strumNote);
		strumArray[i].play(notes[i]+" static");
		
	for i in strumNode.get_children():
		i.scale = strumScale;
		
	notesAppears();
	
	var jsonFile = FileAccess.open(chart_path, FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	chart = jsonData.get_data();
	jsonFile.close();
	
	for i in chart["song"]["notes"]:
		for j in i["sectionNotes"]:
			var noteData = [j[0], j[1], j[2], j[3], i["gfSection"], i["altAnim"], i["mustHitSection"], false];
			if j.size() > 4 && j[4] != null:
				noteData.append(j[4]);
				
			if j.size() > 5 && j[5] != null:
				noteData.append(j[5]);
				
			array_notes.insert(0, noteData);
			
	array_notes.sort_custom(func(a,b): return a[0]<b[0]);
	
func notesAppears():
	var tw = get_tree().create_tween();
	for i in strumNode.get_child_count():
		var strumNote = strumNode.get_child(i);
		tw.tween_property(strumNote, "modulate:a", 1, 0.25+(0.1*i)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		
var notes_to_delete = [];
func _process(delta):
	if !enable:
		return;
		
	for i in array_notes:
		var data = int(i[1])%(8 if !SongData.haveTwoOpponents else 12);
		var distance = (i[0] - Conductor.getSongTime)*Conductor.songSpeed;
		var noteVal1 = i[8] if i.size() > 8 else null;
		var noteVal2 = i[9] if i.size() > 9 else null;
		
		if distance <= 2150 && !i[7]:
			spawnNote(i[0], data, i[2], i[3], i[4], i[5], i[6], noteVal1, noteVal2);
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
		note.scale = strum.scale;
		
		if !note.is_pressing or note.missedLongNote or note.missed:
			note.position.y = strumY + (Conductor.getSongTime - note.strumTime) * (0.45 * Conductor.songSpeed) if GlobalOptions.down_scroll else strumY - (Conductor.getSongTime - note.strumTime) * (0.45 * Conductor.songSpeed);
		else:
			note.position.y = strumY;
			
		if note.isPlayer:
			continue;
			
		if Conductor.getSongTime > 320 + note.strumTime && note.sustainLength <= 0:
			notes_to_delete.append(note);
			
		if Conductor.getSongTime > 335+(note.strumTime+note.ogSustain) && note.sustainLength > 0 && !note.is_pressing:
			notes_to_delete.append(note);
			
		if note.is_a_bad_note:
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
	
	for notes in strumNode.get_children():
		if notes.reset_arrow_anim > 0:
			notes.reset_arrow_anim = max(notes.reset_arrow_anim - 4 * delta, 0);
			
		if notes.reset_arrow_anim <= 0:
			notes.play_note_anim("static");
			
	for i in notes_to_delete:
		notesList.erase(i);
		
func sort_notes(a, b):
	return a.strumTime < b.strumTime;
	
func spawnNote(strumTime, noteData, lenght, type, isGfNote, isAltAnim, isPlayer, value1 = null, value2 = null):
	var note_data = int(noteData)%4;
	var note = Note.new();
	note.is_altAnim = isAltAnim;
	note.strumTime = strumTime;
	note.noteData = note_data;
	note.sustainLength = lenght;
	note.type = type;
	note.isGfNote = isGfNote or (type == "gf sing");
	note.is_altAnim = isAltAnim or (type == "alt anim");
	note.no_anim = (type == "No Animation");
	note.is_hey_note = (type == "Hey!");
	note.must_press = note.isPlayer;
	
	if value1 != null && value2 != null && note.type == "Echo Note":
		note.manyHits = value1;
		note.amount = value2;
		
	note.scale = strumNode.get_child(note.noteData).scale;
	note.rotation = strumNode.get_child(note.noteData).rotation;
	note.modulate.a = strumNode.get_child(note.noteData).modulate.a;
	note.strum_positions.y = strumNode.position.y + strumNode.get_child(note.noteData).position.y;
	note.position.x = strumNode.position.x + strumNode.get_child(note.noteData).position.x;
	
	if note.note != null:
		note.note.offset = strumNode.get_child(note.noteData).note.offset;
		
	notesList.append(note);
	notesList.sort_custom(Callable(self, "sort_notes"));
	
	noteNode.add_child(note);
	
func play_strum_anim(note = null, timer = 0.0):
	strumNode.get_child(note.noteData).reset_arrow_anim = timer;
	strumNode.get_child(note.noteData).play_note_anim("confirm");

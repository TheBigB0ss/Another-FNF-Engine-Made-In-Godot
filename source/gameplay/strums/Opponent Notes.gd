extends Node2D

var notes = ["left", "down", "up", "right"];
var strumArray = [];
var offSetShit = 0;
var coolOffset = 105;
@export var note_type = "NOTE_assets";
@export var note_folder = "default";

var appearNOW = false;

func _ready() -> void:
	for i in notes.size():
		var strumNote = preload("res://source/arrows/note/note.tscn").instantiate();
		strumNote.modulate.a = 0.0;
		strumNote.position.x = offSetShit;
		if !SongData.isPixelStage:
			strumNote.note_skin = note_type;
			strumNote.note_type = note_folder;
			
		strumNote.noteData = i;
		add_child(strumNote);
		offSetShit += coolOffset;
		
		strumArray.append(strumNote.note);
		strumArray[i].play(notes[i]+" static");
		
	var note_appers_now = get_tree().current_scene.get("skipIntro");
	if !note_appers_now:
		notesAppears();
		
	if note_appers_now:
		for i in get_children():
			i.modulate.a = 1;
			
func _process(delta):
	for notes in get_children():
		if notes.reset_arrow_anim > 0:
			notes.reset_arrow_anim = max(notes.reset_arrow_anim - 4 * delta, 0);
			
		if notes.reset_arrow_anim <= 0:
			notes.play_note_anim("static");
			
func notesAppears():
	var tw = get_tree().create_tween();
	for i in get_child_count():
		var strumNote = get_child(i);
		tw.tween_property(strumNote, "modulate:a", 1, 0.25+(0.1*i)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		

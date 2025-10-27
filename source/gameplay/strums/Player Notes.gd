extends Node2D

var notes = ["left", "down", "up", "right"];
var strumArray = [];
var offSetShit = 0;
var coolOffset = 105;
var can_miss = false;
@export var note_type = "NOTE_assets";
@export var note_folder = "default";

var appearNOW = false;

signal canPress(data)
signal releaseNote(data)

func _ready() -> void:
	connect("canPress", pressed);
	connect("releaseNote" , release);
	for i in notes.size():
		var strumNote = preload("res://source/arrows/note/note.tscn").instantiate();
		strumNote.modulate.a = 0.0;
		strumNote.position.x = offSetShit;
		strumNote.strumPressed = false;
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
	var key_id = 0;
	for notes in get_children():
		if notes.reset_arrow_anim > 0 && Global.is_a_bot:
			notes.reset_arrow_anim = max(notes.reset_arrow_anim - 4 * delta, 0);
			
		if notes.reset_arrow_anim <= 0 && Global.is_a_bot:
			notes.play_note_anim("static");
			
		if key_id > get_child_count():
			break;
			
		var note = get_child(key_id);
		var key = "ui_%s"%GlobalOptions.keys[GlobalOptions.keys_list[key_id]][1];
		input_Arrow(key, note);
		
		key_id += 1;
		
func notesAppears():
	var tw = get_tree().create_tween();
	for i in get_child_count():
		var strumNote = get_child(i);
		tw.tween_property(strumNote, "modulate:a", 1, 0.25+(0.1*i)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		
func input_Arrow(key_to_press, ass_note):
	if Input.is_action_just_pressed(key_to_press) && !Global.is_a_bot && Global.is_not_in_cutscene:
		if !ass_note.strumPressed:
			ass_note.play_note_anim("press");
			
			if ass_note.tap:
				get_tree().current_scene.call("playBfMissAnim", ass_note);
				GlobalOptions.emit_signal("ghost_tapping_miss");
				
	if !Input.is_action_pressed(key_to_press) && !Global.is_a_bot:
		ass_note.strumPressed = false;
		ass_note.play_note_anim("static");
		ass_note.tap = !GlobalOptions.ghost_tapping;
		
func pressed(data):
	get_child(data).tap = false;
	
func release(data):
	get_child(data).tap = !GlobalOptions.ghost_tapping;

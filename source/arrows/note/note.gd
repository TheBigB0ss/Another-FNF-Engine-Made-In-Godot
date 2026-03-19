class_name Note extends Sprite2D

@onready var note = AnimatedSprite2D.new();
@onready var strumNote = AnimatedSprite2D.new();
@onready var line = AnimatedSprite2D.new();

@onready var noteLine = Line2D.new();
@onready var noteEnd = Sprite2D.new();

var note_dir = "left";
var custom_note_dir = KEY_LEFT;

var strum_positions = Vector2.ZERO;
var strum_offsets = Vector2.ZERO;

var fileType = "res";
var type = "note";
var noteAnim = "purple";

var note_type = 'default';
var note_skin = "notes";
var note_strum = "StrumlineNotes";
var note_lines = "NOTE_hold_assets";

var isPlayer = false;
var secondOpponentNote = false;

var must_press = false;
var is_pressing = false;
var can_press = false;
var note_pressed = false;

var strumTime = 0;
var noteData = 0;
var isSustain = false;
var sustainLenght = 0.0;

var no_anim = false;
var is_hey_note = false;
var is_altAnim = false;
var isGfNote = false;
var is_a_bad_note = false;

var missed = false;
var release_time = 0.0;
var MissedlongNote = false;
var missTimer = 0.0;

var isStrumNote = false;
var strumPressed = false;
var reset_arrow_anim = 0;
var tap = false;

var chart_passed = false;
var chart_player = false;
var isChartNote = false;

signal opponentNotePressed(note);
signal notePressed(note);

signal noteMissed(note);
signal longNoteMissed(note);

func reload_note_type():
	match type:
		"Hurt Note":
			note.sprite_frames = load("res://assets/images/arrows/hurt note/HurtNote.res" if !SongData.isPixelStage else "res://assets/images/arrows/pixel/hurt note/pixel_hurtNotes.tres");
			is_a_bad_note = true;
			sustainLenght = max(0,0);
			
const notes_settings = {
	0:{
		"dir": "left",
		"anim": "purple"
	},
	1:{
		"dir": "down",
		"anim": "blue"
	},
	2:{
		"dir": "up",
		"anim": "green"
	},
	3:{
		"dir": "right",
		"anim": "red"
	}
};

func reload_note_data():
	note_dir = notes_settings[int(noteData)%4]["dir"];
	noteAnim = notes_settings[int(noteData)%4]["anim"];
	custom_note_dir = GlobalOptions.keys[notes_settings[int(noteData)%4]["dir"]][1];
	
func reload_note():
	if SongData.isPixelStage:
		note.texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
		strumNote.texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
		noteLine.texture_filter = Line2D.TEXTURE_FILTER_NEAREST;
		noteEnd.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST;
		
		note_type = "pixel/default";
		note_skin = "notes";
		note_strum = "NOTE_assets";
		note_lines = "arrowEnds";
		fileType = "tres";
	else:
		note_type = 'default';
		note_skin = "notes";
		note_strum = "StrumlineNotes";
		note_lines = "NOTE_hold_assets"
		fileType = "res";
		
		if type == "note" or type == "":
			match noteAnim:
				"green":
					noteLine.position.x += 2.5;
				"blue":
					noteLine.position.x -= 1.5;
					
	note.sprite_frames = set_note_texture("res://assets/images/arrows/%s/%s.%s"%[note_type, note_skin, fileType]);
	strumNote.sprite_frames = set_note_texture("res://assets/images/arrows/%s/%s.%s"%[note_type, note_strum, fileType]);
	line.sprite_frames = set_note_texture("res://assets/images/arrows/%s/%s.%s"%[note_type, note_lines, fileType]);
	
	var newSustainSpr = SustainNote.new();
	noteLine.texture = newSustainSpr.draw_lien(line.sprite_frames.get_frame_texture("%s hold piece"%[noteAnim], 0));
	noteEnd.texture = line.sprite_frames.get_frame_texture("%s hold end"%[noteAnim], 0);
	
	noteLine.texture_mode = Line2D.LINE_TEXTURE_TILE;
	
var spriteFrames = {};
func set_note_texture(path):
	if !spriteFrames.has(path):
		spriteFrames[path] = load(path);
	return spriteFrames[path];
	
func set_note_scale(parent_scale, pixelNote, newOpponentNote):
	var new_noteScale = parent_scale;
	new_noteScale = Vector2(0.5/parent_scale.x, 0.5/parent_scale.y) if newOpponentNote else Vector2(1/parent_scale.x, 1/parent_scale.y);
	
	if pixelNote:
		new_noteScale *= 7 if !newOpponentNote else 1;
	if GlobalOptions.down_scroll:
		new_noteScale.y *= -1;
		
	return new_noteScale;
	
@onready var main_scene = get_tree().current_scene;
func _ready():
	self.scale = Vector2(0.65, 0.65);
	 
	add_child(strumNote);
	
	add_child(noteLine);
	add_child(note);
	noteLine.add_child(noteEnd);
	
	noteLine.width = 50;
	
	isSustain = (sustainLenght > 0.0);
	
	if isSustain:
		noteLine.add_point(Vector2.ZERO);
		noteLine.add_point(Vector2(0, sustainLenght));
		
	if isStrumNote:
		note.hide();
		noteLine.hide();
		noteEnd.hide();
		strumNote.show();
	else:
		note.show();
		noteLine.show();
		noteEnd.show();
		strumNote.hide();
		
	reload_note_data();
	reload_note();
	reload_note_type();
	note.play(noteAnim);
	
	if SongData.isPixelStage:
		note.scale = Vector2(9,9);
		strumNote.scale = Vector2(9,9);
		noteLine.scale = Vector2(1.20, 1.20);
		
		if secondOpponentNote:
			note.scale = Vector2(4, 4);
			noteLine.scale = Vector2(0.5, 0.5);
			strumNote.modulate.a = 0.60;
			note.modulate.a = 0.60;
	else:
		if secondOpponentNote:
			note.scale = Vector2(0.5, 0.5);
			noteLine.scale = Vector2(0.5, 0.5);
			noteEnd.scale = Vector2(0.5, 0.5);
			strumNote.modulate.a = 0.60;
			note.modulate.a = 0.60;
			
	if isChartNote:
		self.scale = Vector2(0.25, 0.25);
		
	noteLine.modulate.a = 0.5 if GlobalOptions.updated_hud != "classic hud" else 1;
	noteEnd.modulate.a = 0.9 if GlobalOptions.updated_hud != "classic hud" else 1;
	
func _process(delta: float) -> void:
	if isChartNote:
		return;
		
	if self != null && !is_pressing:
		var ms = (strumTime - Conductor.getSongTime);
		can_press = ms <= 175.0 && ms >= -140.0 && isPlayer;
		
	if missed:
		self.modulate.a = 0.3;
		
	if isSustain && is_instance_valid(noteLine):
		noteLine.set_point_position(1, Vector2(0, sustainLenght));
		
		noteLine.scale.y = Conductor.songSpeed/1.5;
		if GlobalOptions.down_scroll:
			noteLine.scale.y *= -1;
			
		if noteEnd != null:
			noteEnd.scale = set_note_scale(noteEnd.get_parent().scale, SongData.isPixelStage, secondOpponentNote);
			noteEnd.position.y = sustainLenght + noteEnd.texture.get_size().y * noteEnd.scale.y / 2.0;
			
	if is_pressing:
		sustainLenght -= (delta * 1000);
		sustainLenght = max(sustainLenght, 0.0);
		
		if isSustain && noteLine != null && noteEnd != null:
			noteEnd.scale.y = abs(min(sustainLenght*Conductor.songSpeed / noteEnd.texture.get_size().y, noteEnd.scale.y));
			noteEnd.position.y = sustainLenght + noteEnd.texture.get_size().y * noteEnd.scale.y / 2.0;
			
			noteLine.set_point_position(1, Vector2(0, sustainLenght));
			
			pressed();
			
			if sustainLenght <= 0:
				missed = false;
				noteEnd.queue_free();
				noteLine.queue_free();
				
	if MissedlongNote:
		missTimer += delta;
		
	if missed or MissedlongNote && sustainLenght > 0.0:
		if missTimer > 0.13:
			can_press = false;
			miss_note();
			
func play_note_anim(anim):
	strumNote.play(str(note_dir, " ", anim));
	
var pressed_emit = false;
func pressed(new_character = null):
	if !isPlayer:
		return;
		
	if sustainLenght <= 0:
		if !pressed_emit:
			if is_a_bad_note:
				miss_note();
			else:
				note_pressed = true;
				emit_signal("notePressed", self);
				main_scene.health = min(main_scene.health+2.30, 100.0);
			pressed_emit = true;
			
		queue_free();
	else:
		if !pressed_emit:
			emit_signal("notePressed", self);
			pressed_emit = true;
			
		if is_instance_valid(note):
			note.queue_free();
			
		if missTimer <= 0:
			main_scene.health = min(main_scene.health+0.11, 100.0);
			
	if missTimer > 0:
		return;
		
	var anim_time = 0.45 if GlobalOptions.isUsingBot else 0.0;
	main_scene.playCharacterAnim(self, main_scene.bf if !is_instance_valid(new_character) else new_character, true);
	main_scene.play_strum_anim(self, false, anim_time, false, true);
	
func opponent_pressed(new_character = null):
	if !isSustain:
		emit_signal("opponentNotePressed", self);
		queue_free();
		
	new_character = (main_scene.dad if !secondOpponentNote else main_scene.new_opponent) if !is_instance_valid(new_character) else new_character;
	main_scene.playCharacterAnim(self, new_character, false);
	main_scene.play_strum_anim(self, !secondOpponentNote, 0.45, secondOpponentNote, true);
	
var emit_miss = false;
func miss_note():
	if emit_miss:
		return;
		
	emit_miss = true;
	missed = true;
	modulate.a = 0.3;
	
	main_scene.health = max(main_scene.health - 4, 0.0);
	if isSustain && sustainLenght > 0.0:
		MissedlongNote = true;
		emit_signal("longNoteMissed", self);
	else:
		emit_signal("noteMissed", self);
		
	main_scene.playBfMissAnim(self);
	

class_name Note extends Sprite2D

@onready var note = AnimatedSprite2D.new();
@onready var strumNote = AnimatedSprite2D.new();
@onready var line = AnimatedSprite2D.new();

@onready var noteLine = Line2D.new();
@onready var noteEnd = Sprite2D.new();

@onready var main_scene = get_tree().current_scene;

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
var secondary_opponent_note = false;

var must_press = false;
var is_pressing = false;
var can_press = false;
var note_pressed = false;

var strumTime = 0;
var noteData = 0;
var isSustain = false;
var sustainLength = 0.0;
var ogSustain = 0.0;

var no_anim = false;
var is_hey_note = false;
var is_altAnim = false;
var isGfNote = false;
var is_a_bad_note = false;

var missed = false;
var release_time = 0.0;
var missedLongNote = false;
var missTimer = 0.0;

var isStrumNote = false;
var strumPressed = false;
var reset_arrow_anim = 0;
var tap = false;

var gotHit = false;
var hitTail = false;
var chart_player = false;
var isChartNote = false;
var ignoreNote = false;

var manyHits = 0;
var amount = 0;

var healthPerHit = 2.10;
var healthPerHolding = 6.50;

var holdSplash = null;

signal opponentNotePressed(note);
signal notePressed(note);

signal noteMissed(note);
signal longNoteMissed(note);

signal noteCreated(note);

func reload_note_type():
	match type:
		"Hurt Note":
			note.sprite_frames = load("res://assets/images/arrows/hurt note/HurtNote.res" if !SongData.isPixelStage else "res://assets/images/arrows/pixel/hurt note/HurtNote_assets_pixel.res");
			is_a_bad_note = true;
			sustainLength = max(0,0);
			
		"Echo Note":
			note.sprite_frames = load("res://assets/images/arrows/echo note/notes.res" if !SongData.isPixelStage else "res://assets/images/arrows/pixel/echo note/echo_pixel.res");
			sustainLength = max(0,0);
		_:
			manyHits = 0;
			amount = 0;
			
const NOTES_SETTINGS = {
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

const NOTES_ANIM = [
	"singLeft",
	"singDown",
	"singUp",
	"singRight"
];

var curNoteAnim = "";

func reload_note_data():
	note_dir = NOTES_SETTINGS[int(noteData)%4]["dir"];
	noteAnim = NOTES_SETTINGS[int(noteData)%4]["anim"];
	custom_note_dir = GlobalOptions.keys[NOTES_SETTINGS[int(noteData)%4]["dir"]][1];
	
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
	noteLine.texture = newSustainSpr.draw_sustain_line(line.sprite_frames.get_frame_texture("%s hold piece"%[noteAnim], 0));
	noteEnd.texture = line.sprite_frames.get_frame_texture("%s hold end"%[noteAnim], 0);
	
	noteLine.texture_mode = Line2D.LINE_TEXTURE_TILE;
	
var spriteFrames = {};
func set_note_texture(path):
	if !spriteFrames.has(path):
		spriteFrames[path] = load(path);
	return spriteFrames[path];
	
func set_note_scale(parent_scale, pixelNote):
	var new_noteScale = parent_scale;
	new_noteScale = Vector2(1/parent_scale.x, 1/parent_scale.y);
	
	if pixelNote:
		new_noteScale *= 7;
	if GlobalOptions.down_scroll:
		new_noteScale.y *= -1;
		
	return new_noteScale;
	
func _ready():
	ogSustain = sustainLength;
	scale = Vector2.ONE * (0.25 if isChartNote else 0.65);
	 
	add_child(strumNote);
	add_child(noteLine);
	add_child(note);
	noteLine.add_child(noteEnd);
	
	noteLine.width = 50;
	
	isSustain = (sustainLength > 0.0);
	
	if isSustain:
		noteLine.add_point(Vector2.ZERO);
		noteLine.add_point(Vector2(0, sustainLength));
		
	note.visible = !isStrumNote;
	noteLine.visible = !isStrumNote;
	noteEnd.visible = !isStrumNote && isSustain;
	strumNote.visible = isStrumNote;
	
	reload_note_data();
	reload_note();
	reload_note_type();
	
	note.play(noteAnim);
	
	if SongData.isPixelStage:
		note.scale = Vector2.ONE * 9;
		strumNote.scale = Vector2.ONE * 9;
		noteLine.scale = Vector2.ONE * 1.2;
		
	var noteAlpha = 1.0;
	if !isChartNote && GlobalOptions.updated_hud != "classic hud":
		noteAlpha = 0.5;
		
	noteLine.modulate.a = noteAlpha;
	noteEnd.modulate.a = 1.0 if noteAlpha == 1 else 0.9;
	
func _process(delta: float) -> void:
	if isChartNote:
		return;
		
	if self != null:
		var ms = (strumTime - Conductor.getSongTime);
		can_press = ms <= 175.0 && ms >= -150.0 && isPlayer;
		
	if missed && !ignoreNote:
		self.modulate.a = 0.3;
		
	if isSustain && is_instance_valid(noteLine):
		noteLine.set_point_position(1, Vector2(0, sustainLength));
		
		noteLine.scale.y = Conductor.songSpeed/1.5;
		if GlobalOptions.down_scroll:
			noteLine.scale.y *= -1;
			
		if noteEnd != null:
			noteEnd.scale = set_note_scale(noteEnd.get_parent().scale, SongData.isPixelStage);
			noteEnd.position.y = sustainLength + noteEnd.texture.get_size().y * noteEnd.scale.y / 2.0;
			
	if is_pressing:
		sustainLength = max(ogSustain - max(Conductor.getSongTime - strumTime, 0.0), 0.0);
		
		if isSustain && noteLine != null && noteEnd != null:
			noteEnd.scale.y = abs(min(sustainLength*Conductor.songSpeed / noteEnd.texture.get_size().y, noteEnd.scale.y));
			noteEnd.position.y = sustainLength + noteEnd.texture.get_size().y * noteEnd.scale.y / 2.0;
			
			noteLine.set_point_position(1, Vector2(0, sustainLength));
			
			if isPlayer:
				pressed();
				if missTimer <= 0:
					main_scene.health = min(main_scene.health+healthPerHolding*delta, 100.0);
					
				if sustainLength <= 0 && GlobalOptions.show_splashes:
					if is_instance_valid(holdSplash):
						if GlobalOptions.isUsingBot:
							holdSplash.queue_free();
						else:
							holdSplash.play_splash(holdSplash.position.x, holdSplash.position.y, "finishpixelCover" if SongData.isPixelStage else "finishCover%s"%[noteAnim]);
							
						holdSplash = null;
						
			else:
				opponent_pressed();
				
			if sustainLength <= 0:
				missed = false;
				noteEnd.queue_free();
				noteLine.queue_free();
				
	if missedLongNote:
		missTimer += delta;
		
	if missed or missedLongNote && sustainLength > 0.0:
		if missTimer > 0.13:
			can_press = false;
			is_pressing = false;
			if is_instance_valid(holdSplash):
				holdSplash.queue_free();
			miss_note();
			
func play_note_anim(anim):
	strumNote.play(str(note_dir, " ", anim));
	
var pressed_emit = false;
func pressed(new_character = null):
	if missed:
		return;
		
	curNoteAnim = NOTES_ANIM[noteData];
	new_character = main_scene.bf if !is_instance_valid(new_character) else new_character;
	
	if !new_character.is_player or new_character.curCharacter == "tankman":
		curNoteAnim = swap_sing_anims("singLeft", "singRight");
		
	new_character.curNote = self;
	
	if !is_a_bad_note && !pressed_emit:
		main_scene.health = min(main_scene.health+healthPerHit, 100.0);
		
	emitPress(false);
	if sustainLength <= 0:
		new_character.animNote = self;
		
		if is_a_bad_note:
			miss_note();
			
		destroy_note();
	else:
		if is_instance_valid(note):
			note.queue_free();
			
	if missTimer > 0:
		return;
		
	var anim_time = 0.45 if GlobalOptions.isUsingBot else 0.0;
	main_scene.playCharacterAnim(self, new_character);
	main_scene.play_strum_anim(self, false, anim_time, true);
	
func opponent_pressed(new_character = null):
	curNoteAnim = NOTES_ANIM[noteData];
	new_character = main_scene.dad if !is_instance_valid(new_character) else new_character;
	
	if new_character.is_player && new_character.curCharacter != "tankman" && new_character.curCharacter != "pico":
		curNoteAnim = swap_sing_anims("singLeft", "singRight");
		
	new_character.curNote = self;
	
	emitPress(true);
	
	if sustainLength <= 0:
		if is_instance_valid(holdSplash):
			holdSplash.queue_free();
			holdSplash = null;
			
		new_character.animNote = self;
		destroy_note();
		
	main_scene.playCharacterAnim(self, new_character);
	if !secondary_opponent_note:
		main_scene.play_strum_anim(self, true, 0.45, true);
		
func emitPress(is_opponent):
	if pressed_emit:
		return;
		
	if GlobalOptions.playNoteHitSound:
		Sound.add_new_sound("hitNotePlayer" if !is_opponent else "hitNoteOpponent");
		
	if !is_opponent:
		emit_signal("notePressed", self);
	else:
		emit_signal("opponentNotePressed", self);
		
	pressed_emit = true;
	
var emit_miss = false;
func miss_note():
	if ignoreNote:
		return;
		
	if emit_miss:
		return;
		
	curNoteAnim = NOTES_ANIM[noteData];
	main_scene.health = max(main_scene.health - 4, 0.0);
	
	if isSustain:
		emit_signal("longNoteMissed", self);
	else:
		emit_signal("noteMissed", self);
		
	main_scene.playBfMissAnim(self);
	missed = true;
	emit_miss = true;
	
func destroy_note():
	if manyHits > 0 && type == "Echo Note":
		var tween = create_tween();
		tween.tween_property(self, "strumTime", strumTime + (amount * Conductor.crochet), Conductor.crochet / 1000.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT);
		
		manyHits -= 1;
		
		if manyHits <= 0:
			queue_free();
			
		pressed_emit = false;
		note_pressed = false;
		
		return;
		
	queue_free();
	
func swap_sing_anims(pos1, pos2):
	if curNoteAnim == pos1:
		return pos2;
	if curNoteAnim == pos2:
		return pos1;
		
	return curNoteAnim;

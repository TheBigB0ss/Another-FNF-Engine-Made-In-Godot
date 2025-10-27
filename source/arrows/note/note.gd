extends Node2D

@onready var note = $Note;
@onready var note_line = $noteLine;
@onready var note_end = $"noteLine/noteEnd";

var note_dir = "left";
var custom_note_dir = KEY_LEFT;
var note_release = false;

var strumY = null;
var strumX = null;
var linePos = Vector2.ZERO;

var type = "note";
var noteAnim = "purple";
var note_type = 'default';
var note_skin = "NOTE_assets";

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

var emit_longNote = false;

var missed = false;
var long_press_missed = false;
var emit_longNoteMiss = false;
var long_missed = false;
var long_note_missTimer = 0.0;

var strumPressed = false;
var reset_arrow_anim = 0;
var tap = false;

var chart_player = false;
var chart_passed = false;

func reload_note_type():
	match type:
		"Hurt Note":
			note.sprite_frames = load("res://assets/images/arrows/hurt note/HurtNote.res" if !SongData.isPixelStage else "res://assets/images/arrows/pixel/hurt note/pixel_hurtNotes.tres");
			is_a_bad_note = true;
			if isSustain:
				var new_texture = note.sprite_frames.get_frame_texture("%s hold piece"%[noteAnim], 0);
				var image = new_texture.get_image();
				image.rotate_90(CLOCKWISE);
				
				note_line.texture = ImageTexture.create_from_image(image) if !SongData.isPixelStage else load("res://assets/images/arrows/pixel/hurt note/pieces/hold.png");
				note_end.texture = note.sprite_frames.get_frame_texture("%s hold end"%[noteAnim], 0) if !SongData.isPixelStage else load("res://assets/images/arrows/pixel/hurt note/pieces/end.png");
				
		"Kill Note":
			note.sprite_frames = load("res://assets/images/arrows/kill note/kill_note.res");
			is_a_bad_note = true;
			if isSustain:
				note_line.texture = load("res://assets/images/arrows/kill note/pieces/killNOTEpiece.png");
				note_end.texture = load("res://assets/images/arrows/kill note/pieces/killEnd.png");
				
func reload_note():
	match noteData:
		0, 4, 8:
			note_dir = "left";
			noteAnim = "purple";
			custom_note_dir = GlobalOptions.keys["left"][1];
		1, 5, 9:
			note_dir = "down";
			noteAnim = "blue";
			custom_note_dir = GlobalOptions.keys["down"][1];
		2, 6, 10:
			note_dir = "up";
			noteAnim = "green";
			custom_note_dir = GlobalOptions.keys["up"][1];
		3, 7, 11:
			note_dir = "right";
			noteAnim = "red";
			custom_note_dir = GlobalOptions.keys["right"][1];
			
	if SongData.isPixelStage:
		note.texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
		note_line.texture_filter = Line2D.TEXTURE_FILTER_NEAREST;
		note_end.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST;
		
		note.sprite_frames = load("res://assets/images/arrows/pixel/%s/%s.tres"%[note_type, note_skin]);
		note.scale = Vector2(9,9);
		
		if isSustain or sustainLenght > 0.0:
			note_line.texture = load("res://assets/images/arrows/pixel/%s/pieces/%s hold piece.png"%[note_type, noteAnim]);
			note_end.texture = load("res://assets/images/arrows/pixel/%s/pieces/%s hold end.png"%[note_type, noteAnim]);
			note_end.scale = Vector2(7,7);
			
		if secondOpponentNote:
			note.scale = Vector2(4, 4);
			note.modulate.a = 0.60;
			note_line.scale = Vector2(0.5, 0.5);
	else:
		note.sprite_frames = load("res://assets/images/arrows/%s/%s.res"%[note_type, note_skin]);
		
		if isSustain or sustainLenght > 0.0:
			var new_texture = note.sprite_frames.get_frame_texture("%s hold piece"%[noteAnim], 0);
			var image = new_texture.get_image();
			image.rotate_90(CLOCKWISE);
			
			note_line.texture = ImageTexture.create_from_image(image) if note.sprite_frames.has_animation("%s hold piece"%[noteAnim]) else load("res://assets/images/arrows/%s/pieces/%s hold piece.png"%[note_type, noteAnim]);
			note_end.texture = note.sprite_frames.get_frame_texture("%s hold end"%[noteAnim], 0) if note.sprite_frames.has_animation("%s hold end"%[noteAnim]) else load("res://assets/images/arrows/%s/pieces/%s hold end.png"%[note_type, noteAnim]);
			
			if type == "note" or type == "":
				match noteAnim:
					"green":
						note_line.position.x += 2.5;
					"blue":
						note_line.position.x -= 1.5;
						
		if secondOpponentNote:
			note.scale = Vector2(0.5, 0.5);
			note_line.scale = Vector2(0.5, 0.5);
			note_end.scale = Vector2(0.5, 0.5);
			
	note_line.modulate.a = 0.5 if GlobalOptions.updated_hud != "classic hud" else 1;
	note_end.modulate.a = 0.9 if GlobalOptions.updated_hud != "classic hud" else 1;
	
func _ready():
	reload_note();
	reload_note_type();
	
	long_press_missed = false;
	long_note_missTimer = 0.0;
	note.play(noteAnim);
	
	note_line.texture_mode = Line2D.LINE_TEXTURE_TILE;
	
func _process(delta):
	if missed or long_missed:
		self.modulate.a = 0.3;
		
	isSustain = (sustainLenght > 0.0);
	if sustainLenght > 0 && note_line != null:
		if note_line.points.size() == 0:
			note_line.add_point(Vector2(0, 0));
			note_line.add_point(Vector2(0, sustainLenght));
		else:
			note_line.set_point_position(1, Vector2(0, sustainLenght));
			
		note_line.scale.y = Conductor.songSpeed/1.5;
		if GlobalOptions.down_scroll:
			note_line.scale.y *= -1;
			
		if note_end != null:
			note_end.scale = set_note_scale(note_end.get_parent().scale, SongData.isPixelStage, secondOpponentNote);
			note_end.position.y = sustainLenght + note_end.texture.get_size().y * note_end.scale.y / 2.0;
			
	if is_pressing:
		sustainLenght -= (delta * 1000);
		sustainLenght = max(sustainLenght, 0.0);
		
		if isSustain && note_line != null && note_end != null:
			var scale_shit = (1.5 if !SongData.isPixelStage else 8.75);
			var original_height = note_end.texture.get_size().y;
			var scale_factor = clamp(sustainLenght / original_height * scale_shit, 0.0, scale_shit);
			
			note_end.position.y = sustainLenght + original_height * note_end.scale.y / 2.0;
			note_end.scale.y = (scale_factor / Conductor.songSpeed) * (1.2 if SongData.isPixelStage else 1.0);
			
			note_release = !Input.is_action_pressed("ui_" + custom_note_dir) && isPlayer;
			if note_release && !Global.is_a_bot:
				long_press_missed = true;
				is_pressing = true;
				var newPos = linePos.y - strumY if !GlobalOptions.down_scroll else strumY - linePos.y;
				note_line.global_position.y = newPos;
				
			if sustainLenght <= 0:
				missed = false;
				note_end.queue_free();
				note_line.queue_free();
			else:
				if !long_missed:
					longNote_Pressed();
					
			note_line.set_point_position(1, Vector2(0, sustainLenght));
			
	if long_press_missed && isSustain:
		long_note_missTimer += delta;
		
	if !missed:
		if long_note_missTimer > 0.13 && !emit_longNoteMiss && sustainLenght > 0.0:
			can_press = false;
			long_missed = true;
			long_press_missed = false;
			is_pressing = true;
			
			longNote_Released();
			
			emit_longNoteMiss = true;
			
func pressed():
	if !isSustain or sustainLenght <= 0:
		if is_a_bad_note:
			miss_note();
			self.queue_free();
		else:
			note_pressed = true;
			self.queue_free();
			Global.emit_signal('notePressed', self);
			
		if Global.is_a_bot:
			get_tree().current_scene.call("play_strum_anim", self, false, 0.45 if GlobalOptions.updated_hud != "classic hud" else 0.90, false, true);
		else:
			get_tree().current_scene.call("play_strum_anim", self, false, 0.0, false, false);
			
var pressed_emit = false;
func longNote_Pressed():
	if !(isSustain or sustainLenght > 0):
		return;
		
	if isPlayer:
		if note != null:
			note.queue_free();
			
		if !missed && is_pressing && long_note_missTimer == 0.0 && isPlayer && !long_press_missed:
			if is_a_bad_note:
				miss_note();
			else:
				if !Global.is_a_bot:
					if !note_release:
						get_tree().current_scene.call("play_strum_anim", self, false, 0.30, false, false); 
				else: 
					get_tree().current_scene.call("play_strum_anim", self, false, 0.30, false, true);
					
				get_tree().current_scene.call("playBfAnim", self);
				
		note_pressed = true;
		is_pressing = true;
		self.position.y = strumY;
		
		if !pressed_emit && !is_a_bad_note:
			Global.emit_signal('notePressed', self);
			pressed_emit = true;
	else:
		get_tree().current_scene.call("play_strum_anim", self, true if !secondOpponentNote else false, 0.30, false if !secondOpponentNote else true, true);
		
func longNote_Released():
	missed = false;
	if isSustain or sustainLenght > 0:
		if !is_a_bad_note:
			miss_note();
		else:
			is_pressing = false;
			
func opponent_pressed():
	self.queue_free();
	get_tree().current_scene.call("play_strum_anim", self, true if !secondOpponentNote else false, 0.45 if GlobalOptions.updated_hud != "classic hud" else 0.90, false if !secondOpponentNote else true, true);
	
var emit_miss = false;
func miss_note():
	self.modulate.a = 0.3;
	missed = true;
	
	if emit_miss:
		return;
		
	if sustainLenght > 0.0 or isSustain:
		if is_a_bad_note:
			is_pressing = true;
		else:
			long_press_missed = true;
			long_missed = true;
			if note_line != null:
				linePos = note_line.global_position;
				
		Global.emit_signal('longNoteMissed');
	else:
		Global.emit_signal('noteMissed');
		
	emit_miss = true;
	
	get_tree().current_scene.call("playBfMissAnim", self);
	
func play_note_anim(anim):
	note.play(str(note_dir, " ", anim));
	
func set_note_scale(parent_scale, pixelNote, newOpponentNote):
	var new_noteScale = parent_scale;
	new_noteScale = Vector2(0.5/parent_scale.x, 0.5/parent_scale.y) if newOpponentNote else Vector2(1/parent_scale.x, 1/parent_scale.y);
	
	if pixelNote:
		new_noteScale *= 7 if !newOpponentNote else 1;
	if GlobalOptions.down_scroll:
		new_noteScale.y *= -1;
		
	return new_noteScale;
	

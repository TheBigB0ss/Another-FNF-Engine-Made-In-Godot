class_name EventLoader extends Node

var array_events_notes = [];
var event_index = 0;

@export var scene:Node2D;
var main_scene = null;

var current_lyric:Lyric;

var bf;
var dad;
var gf;

var iconP1;
var iconP2;

var stageGrp;
var stage;

signal event_emit(event_name, args);

func _ready() -> void:
	main_scene = scene;
	event_emit.connect(eventEmit);
	reload_events();
	
static func eventEmit(eventName, args):
	ScriptLoader.call_func("on_event", [eventName, args]);
	
func reload_events() -> void:
	array_events_notes.clear();
	event_index = 0;
	
	for event in SongData.songEvents:
		if event.size() < 5:
			continue;
			
		array_events_notes.append([event[0], event[1], event[2], event[3], event[4]]);
		
	array_events_notes.sort_custom(func(a, b): return a[0] < b[0]);
	
func _process(_delta: float) -> void:
	while event_index < array_events_notes.size():
		var event = array_events_notes[event_index];
		
		if Conductor.getSongTime < event[0]:
			break;
			
		event_index += 1;
		trigger_event(event[2], event[3], event[4]);
		
func trigger_event(event_name, value1, value2):
	event_emit.emit(event_name, [value1, value2]);
	
	match event_name:
		"change song speed":
			var speed = str(value1).to_float()
			
			if str(value2).to_lower() == "true":
				create_tween().tween_property(Conductor, "songSpeed", speed, Conductor.crochet / 1000.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT);
			else:
				Conductor.songSpeed = speed;
				
		"change song pitch":
			var pitch = str(value1).to_float();
			
			if str(value2).to_lower() == "true":
				var duration = Conductor.crochet / 1000.0;
				
				if is_instance_valid(main_scene.inst):
					create_tween().tween_property(main_scene.inst, "pitch_scale", pitch, duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT);
					
				if is_instance_valid(main_scene.voices):
					create_tween().tween_property(main_scene.voices, "pitch_scale", pitch, duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT);
					
				create_tween().tween_property(Conductor, "songSpeed", pitch, duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT);
				
			else:
				if is_instance_valid(main_scene.inst):
					main_scene.inst.pitch_scale = pitch;
					
				if is_instance_valid(main_scene.voices):
					main_scene.voices.pitch_scale = pitch;
					
				Conductor.songSpeed = pitch;
				
		"change character":
			changeChar(str(value1), str(value2));
			
		"change bg":
			changeBg(str(value1));
			
		"play anim":
			characterPlayAnim(str(value1), str(value2));
			
		"flash":
			Flash.flashAppears(str(value1).to_float(), Color.from_string(str(value2), Color.WHITE));
			
		"add cam zoom":
			if is_instance_valid(main_scene) && is_instance_valid(main_scene.sectionCamera):
				var zoom_value = str(value1).to_float();
				main_scene.sectionCamera.zoom = Vector2.ONE * zoom_value;
				
		"set lyric":
			set_lyric(str(value1), str(value2));
			
func set_lyric(text, steps_text) :
	if is_instance_valid(current_lyric):
		current_lyric.queue_free();
		current_lyric = null;
		
	if text.is_empty() or !is_instance_valid(main_scene):
		return
		
	var steps = [];
	
	if !steps_text.is_empty():
		for step in steps_text.split(","):
			steps.append(int(step.strip_edges()));
			
	var lyric = Lyric.new();
	lyric.position = Vector2(350.0, 515.0);
	lyric.set_size(Vector2(600.0, 100.0));
	lyric.set_new_text(text, steps);
	
	main_scene.hud.add_child(lyric);
	current_lyric = lyric;
	
func remove_character(character) -> void:
	if !is_instance_valid(character):
		return;
		
	if character.get_parent():
		character.get_parent().remove_child(character);
		
	character.queue_free();
	

func changeChar(id, newCharacter) -> void:
	if !is_instance_valid(main_scene):
		return;
		
	var character = null;
	var position = Vector2.ZERO;
	var z_index = 0;
	var layer = 1;
	
	match id:
		"0", "bf":
			character = main_scene.bf;
			position = SongData.gfStagePosition if newCharacter == "gf" else SongData.player1StagePosition;
			z_index = SongData.player1Zindex;
			layer = 4;
			
		"1", "dad":
			character = main_scene.dad;
			position = SongData.gfStagePosition if newCharacter == "gf" else SongData.player2StagePosition;
			z_index = SongData.player2Zindex;
			layer = 3;
			
		"2", "gf":
			character = main_scene.gf;
			position = SongData.gfStagePosition;
			z_index = SongData.gfZindex;
			layer = 1;
			
		_:
			return;
			
	if !is_instance_valid(character):
		return;
		
	remove_character(character);
	
	var new_char = character.init_character(main_scene, position, z_index, newCharacter, layer);
	
	if !is_instance_valid(new_char):
		return;
		
	match id:
		"0", "bf":
			main_scene.bf = new_char;
			bf = new_char;
			bf.update_character_side(true);
			
			update_icon(main_scene.iconP1, new_char);
			
			if GlobalOptions.updated_hud != "classic hud":
				main_scene.healthBar.tint_progress = new_char.healthBar_Color;
				
		"1", "dad":
			main_scene.dad = new_char;
			dad = new_char;
			dad.update_character_side(false);
			
			update_icon(main_scene.iconP2, new_char);
			
			if GlobalOptions.updated_hud != "classic hud":
				main_scene.healthBar.tint_under = new_char.healthBar_Color;
				
		"2", "gf":
			main_scene.gf = new_char;
			gf = new_char;
			
func update_icon(icon, character) -> void:
	if !is_instance_valid(icon) or !is_instance_valid(character):
		return;
		
	if !icon is Icon:
		return;
		
	if icon.is_animated:
		icon.icon_frames = "assets/images/icons/animated/%s/%s" % [character.curIcon, character.curIcon];
		icon.icon_char = character.curIcon;
		icon.reload_animated_icon();
	else:
		icon.reload_icon(character.curIcon);
		
func characterPlayAnim(id, anim):
	var target = null;
	
	match id:
		"0", "bf":
			target = main_scene.bf;
		"1", "dad":
			target = main_scene.dad;
		"2", "gf":
			target = main_scene.gf;
			
	if !is_instance_valid(target):
		return;
		
	target._playAnim(anim, true);
	
func changeBg(newBg):
	if !is_instance_valid(main_scene):
		return;
		
	var stage_path = "res://source/stages/%s/%s.tscn"%[newBg, newBg];
	
	if !ResourceLoader.exists(stage_path):
		return;
		
	var packed_stage = load(stage_path);
	
	if packed_stage == null:
		return;
		
	var new_stage = packed_stage.instantiate();
	
	for child in main_scene.stageGrp.get_children():
		main_scene.stageGrp.remove_child(child);
		child.queue_free();
		
	main_scene.stage = new_stage;
	
	if new_stage is Stage:
		new_stage.init_game(main_scene);
		
	SongData.loadStageJson(newBg);
	
	main_scene.curStage = newBg.to_lower();
	main_scene.stageGrp.add_child(new_stage);
	
	if !is_instance_valid(main_scene):
		return;
		
	if is_instance_valid(main_scene.bf):
		main_scene.bf.position = SongData.player1StagePosition;
		main_scene.bf.z_index = SongData.player1Zindex;
		
	if is_instance_valid(main_scene.gf):
		main_scene.gf.position = SongData.gfStagePosition;
		main_scene.gf.z_index = SongData.gfZindex;
		
	if is_instance_valid(main_scene.dad):
		main_scene.dad.position = (SongData.gfStagePosition if SongData.player2 == "gf" else SongData.player2StagePosition);
		main_scene.dad.z_index = SongData.player2Zindex;
		

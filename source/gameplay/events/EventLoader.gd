class_name EventLoader extends Node

var array_events_notes = [];
@export var scene:Node2D;
var main_scene = null;

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
	reload_events();
	
func reload_events():
	array_events_notes.clear();
	for i in SongData.songEvents:
		array_events_notes.insert(0, [i[0], i[1], i[2], i[3], i[4]]);
		
	array_events_notes.sort_custom(func(a, b): return a[0] < b[0]);
	
func _process(_delta: float) -> void:
	while !array_events_notes.is_empty():
		var event = array_events_notes[0];
		if Conductor.getSongTime < event[0]:
			break;
			
		set_event(event[2], event[3], event[4]);
		array_events_notes.pop_front();
		
func set_event(new_event, new_value1, new_value2):
	var event = new_event;
	var value1 = new_value1;
	var value2 = new_value2;
	
	trigger_event(event, value1, value2);
	
func trigger_event(event_name, value1, value2):
	emit_signal("event_emit", event_name, [value1, value2]);
	
	match event_name:
		"change song speed":
			if value2 == "true":
				var songTween = create_tween();
				songTween.tween_property(Conductor, "songSpeed", value1.to_float(), Conductor.crochet / 1000.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT);
			else:
				Conductor.songSpeed = value1.to_float();
				
		"change song pitch":
			if value2 == "true":
				var instTween = create_tween();
				instTween.tween_property(main_scene.inst, "pitch_scale", value1.to_float(), Conductor.crochet / 1000.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT);
				
				var voicesTween = create_tween();
				voicesTween.tween_property(main_scene.voices, "pitch_scale", value1.to_float(), Conductor.crochet / 1000.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT);
				
				var songTween = create_tween();
				songTween.tween_property(Conductor, "songSpeed", value1.to_float(), Conductor.crochet / 1000.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT);
			else:
				main_scene.inst.pitch_scale = value1.to_float();
				main_scene.voices.pitch_scale = value1.to_float();
				Conductor.songSpeed = value1.to_float();
				
		"change character":
			changeChar(value1, value2);
			
		"change bg":
			changeBg(value1);
			
		"play anim":
			characterPlayAnim(value1, value2);
			
		"flash":
			Flash.flashAppears(value1.to_float(), Color(value2));
			
		"add cam zoom":
			main_scene.sectionCamera.zoom = Vector2(value1.to_float(), value1.to_float());
			
		"set lyric":
			var string_steps = value2.split(",");
			var steps = [];
			for i in string_steps:
				steps.append(int(i));
				
			if value2 == "":
				steps = [];
				
			var newLyric = Lyric.new();
			newLyric.position = Vector2(350.0, 275.0);
			newLyric.position.y += 240;
			newLyric.set_size(Vector2(600, 100));
			newLyric.set_new_text(value1, steps);
			main_scene.hud.add_child(newLyric);
			
func remove_character(char_to_remove):
	main_scene.remove_child(char_to_remove);
	char_to_remove.queue_free();
	
func changeChar(id, newCharacter):
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
			
	remove_character(character);
	
	var newChar = character.init_character(main_scene, position, z_index, newCharacter, layer);
	
	match id:
		"0", "bf":
			main_scene.bf = newChar
			bf = newChar;
			main_scene.bf.character.flip_h = !main_scene.bf.is_player;
			
			if !main_scene.bf.is_player:
				for i in main_scene.bf.camera_pos.size()-1:
					main_scene.bf.camera_pos[i] *= -1;
					
			update_icon(main_scene.iconP1, newChar);
			if GlobalOptions.updated_hud != "classic hud":
				main_scene.healthBar.tint_progress = newChar.healthBar_Color;
				
		"1", "dad":
			main_scene.dad = newChar;
			dad = newChar;
			main_scene.dad.character.flip_h = main_scene.dad.is_player;
			
			if main_scene.dad.is_player:
				for i in main_scene.dad.camera_pos.size()-1:
					main_scene.dad.camera_pos[i] *= -1;
					
			update_icon(main_scene.iconP2, newChar);
			if GlobalOptions.updated_hud != "classic hud":
				main_scene.healthBar.tint_under = newChar.healthBar_Color;
				
		"2", "gf":
			main_scene.gf = newChar;
			gf = newChar;
			
func update_icon(icon, character):
	if icon is Icon:
		icon.reload_icon(character.curIcon);
		
	elif icon is AnimatedIcon:
		icon.icon_frames = "assets/images/icons/animated/%s/%s.res" % [character.curIcon, character.curIcon];
		icon.icon_char = character.curIcon;
		
func changeBg(newBg):
	for i in main_scene.stageGrp.get_children():
		main_scene.stageGrp.remove_child(i);
		i.queue_free();
		
	main_scene.stage = load("res://source/stages/%s/%s.tscn"%[newBg, newBg]).instantiate();
	if main_scene.stage is Stage:
		main_scene.stage.init_game(main_scene);
		
	SongData.loadStageJson(newBg);
	
	main_scene.curStage = newBg.to_lower();
	main_scene.stageGrp.add_child(main_scene.stage);
	
	main_scene.bf.position = SongData.player1StagePosition;
	main_scene.bf.z_index = SongData.player1Zindex;
	
	if main_scene.gf != null:
		main_scene.gf.position = SongData.gfStagePosition;
		main_scene.gf.z_index = SongData.gfZindex;
		
	main_scene.dad.position = SongData.gfStagePosition if SongData.player2 == "gf" else SongData.player2StagePosition;
	main_scene.dad.z_index = SongData.player2Zindex;
	
func characterPlayAnim(id, anim):
	match id:
		"0", "bf":
			main_scene.bf._playAnim(anim, true);
			
		"1", "dad":
			main_scene.dad._playAnim(anim, true);
			
		"2", "gf":
			if SongData.gfPlayer != "" && main_scene.gf != null:
				main_scene.gf._playAnim(anim, true);
				

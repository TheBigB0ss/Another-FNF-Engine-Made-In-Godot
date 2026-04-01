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

signal event_emit(event_name);

func _ready() -> void:
	main_scene = scene;
	if !SongData.songEvents.is_empty():
		for i in SongData.songEvents:
			array_events_notes.insert(0, [i[0], i[1], i[2], i[3], i[4]]);
			
func load_():
	bf = scene.bf;
	dad = scene.dad;
	gf = scene.gf;
	
	iconP1 = scene.iconP1;
	iconP2 = scene.iconP2;
	
	stageGrp = scene.stageGrp;
	stage = scene.stage;
	
func _process(_delta: float) -> void:
	if array_events_notes != [] or array_events_notes != null:
		for i in array_events_notes:
			if Conductor.getSongTime >= i[0]:
				set_event(i[2], i[3], i[4]);
				array_events_notes.erase(i);
				
func set_event(new_event, new_value1, new_value2):
	var event = new_event;
	var value1 = new_value1;
	var value2 = new_value2;
	
	trigger_event(event, value1, value2);
	
func trigger_event(event_name, value1, value2):
	emit_signal("event_emit", event_name);
	match event_name:
		"change song speed":
			Conductor.songSpeed = value1.to_float();
			
		"change song pitch":
			main_scene.inst.pitch_scale = lerp(main_scene.inst.pitch_scale, value1.to_float(), value2.to_float());
			main_scene.voices.pitch_scale = lerp(main_scene.voices.pitch_scale, value1.to_float(), value2.to_float());
			Conductor.songSpeed = lerp(Conductor.songSpeed, value1.to_float(), value2.to_float());
			
		"change character":
			changeChar(value1, value2);
			
		"change bg":
			changeBg(value1);
			
		"play anim":
			characterPlayAnim(value1, value2);
			
		"flash":
			Flash.flashAppears(value1.to_float(), Color(value2));
			
		#"set camera position":
		#	set_new_camPos(value1, value2);
			
		"add cam zoom":
			main_scene.sectionCamera.zoom = Vector2(value1.to_float(), value1.to_float());
			
		"spawn popUp":
			var new_popUp = preload("res://source/gameplay/events/pop ups/popUps.tscn").instantiate();
			main_scene.hud.add_child(new_popUp);
			
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
	match id:
		"0", "bf":
			remove_character(main_scene.bf);
			var newCharacterPosition = SongData.gfStagePosition if newCharacter == "gf" else SongData.player1StagePosition;
			var newChar = main_scene.add_character(newCharacterPosition, SongData.player1Zindex, newCharacter, 4);
			
			main_scene.bf = newChar;
			bf = newChar;
			
			if main_scene.iconP1 is Icon:
				main_scene.iconP1.reload_icon(main_scene.bf.curIcon);
			elif main_scene.iconP1 is AnimatedIcon:
				main_scene.iconP1.icon_frames = "assets/images/icons/animated/%s/%s.res"%[main_scene.bf.curIcon, main_scene.bf.curIcon];
				main_scene.iconP1.icon_char = main_scene.bf.curIcon;
				
			main_scene.bf.character.flip_h = !main_scene.bf.is_player;
			if !main_scene.bf.is_player:
				for i in main_scene.bf.camera_pos.size():
					main_scene.bf.camera_pos[i] *= -1;
					
			main_scene.healthBar.tint_progress = Color("#ff000f") if GlobalOptions.updated_hud == "classic hud" else bf.healthBar_Color;
			
		"1", "dad":
			remove_character(main_scene.dad);
			var newCharacterPosition = SongData.gfStagePosition if SongData.player2 == "gf" else SongData.player2StagePosition;
			var newChar = main_scene.add_character(newCharacterPosition, SongData.player2Zindex, newCharacter, 3);
			
			main_scene.dad = newChar;
			dad = newChar;
			
			if main_scene.iconP2 is Icon:
				main_scene.iconP2.reload_icon(main_scene.dad.curIcon);
			elif main_scene.iconP2 is AnimatedIcon:
				main_scene.iconP2.icon_frames = "assets/images/icons/animated/%s/%s.res"%[main_scene.dad.curIcon, main_scene.dad.curIcon];
				main_scene.iconP2.icon_char = main_scene.dad.curIcon;
				
			main_scene.dad.character.flip_h = dad.is_player;
			if main_scene.dad.is_player:
				for i in main_scene.dad.camera_pos.size():
					main_scene.dad.camera_pos[i] *= -1;
					
			main_scene.healthBar.tint_under = Color("#ff000f") if GlobalOptions.updated_hud == "classic hud" else dad.healthBar_Color;
			
		"2", "gf":
			remove_character(main_scene.gf);
			var newCharacterPosition = SongData.gfStagePosition;
			var newChar = main_scene.add_character(newCharacterPosition, SongData.gfZindex, newCharacter, 1);
			
			main_scene.gf = newChar;
			gf = newChar;
			
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
			main_scene.bf._playAnim(anim);
			
		"1", "dad":
			main_scene.dad._playAnim(anim);
			
		"2", "gf":
			if SongData.gfPlayer != "" && main_scene.gf != null:
				main_scene.gf._playAnim(anim);
				
#func set_new_camPos(pos, just_for_one_section):
	#var splitedPos = pos.split(",");
	#var new_cam_pos = Vector2(splitedPos[0].to_int(), splitedPos[1].to_int());
	#
	#if main_scene.sectionCamera != null && SongData.isPlaying:
		#main_scene.move_cam(GlobalOptions.updated_cam == "smooth", new_cam_pos);
		#
	#main_scene.camera_focus = (just_for_one_section == "true");
	#

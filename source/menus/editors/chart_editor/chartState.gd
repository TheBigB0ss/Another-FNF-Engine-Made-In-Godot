extends Node2D

@onready var voices = $chart_voices;
@onready var inst = $chart_inst;

var songLength = 0.0;

@onready var iconP1 = $'grid_objs/icons/icon_player';
@onready var iconP2 = $'grid_objs/icons/icon_opponent';

@onready var chart_cam = $'Camera2D';
@onready var chart_bg = $bg;

@onready var event_text = $chart_UI/chart_objs/chartTab/eventsWindow/events_description;

@onready var grid = $'grid_objs/grid';

@onready var song_line = $'grid_objs/song_line';
@onready var selection = $'grid_objs/selection_box';

@onready var notes = $'grid_objs/notes';
@onready var sustain_notes = $'grid_objs/sustain_notes';

@onready var player1Options = $chart_UI/chart_objs/chartTab/chartWindow/player1;
@onready var player2Options = $chart_UI/chart_objs/chartTab/chartWindow/player2;
@onready var gfOptions = $chart_UI/chart_objs/chartTab/chartWindow/gf;
@onready var stageOptions = $chart_UI/chart_objs/chartTab/chartWindow/stage;

@onready var note_type_button = $chart_UI/chart_objs/chartTab/notesWindow/note_type;
@onready var events_button = $chart_UI/chart_objs/chartTab/eventsWindow/event;

@onready var cool_file_save = $"FileDialog";
@onready var cool_events_save = $'FileDialogEvents';

@onready var chartBf = $chart_UI/chart_objs/chartTab/playerPreviewWindow/ChartBf;
@onready var chartEnemy = $chart_UI/chart_objs/chartTab/opponentPreviewWindow/ChartEnemy;

@onready var chart_info = $chart_UI/chart_objs/infos/chart_info;
@onready var timeBar = $chart_UI/chart_objs/infos/timeBar;
@onready var songPointer = $chart_UI/chart_objs/infos/songPointer;

var curselected_note = [];
var curselected_event = []:
	set(val):
		if curselected_event != val:
			curselected_event = val;
			
			notesEvents.clear();
			for i in SongData.songEvents.size():
				if SongData.songEvents[i].size() <= 2 or curselected_event.is_empty():
					continue;
					
				if SongData.songEvents[i][0] == curselected_event[0] && int(SongData.songEvents[i][1]) == int(curselected_event[1]):
					notesEvents.add_item(SongData.songEvents[i][2]);
					notesEvents.set_item_metadata(notesEvents.item_count - 1, i);
					
var event_text_array = [];
var note_types = [
	"", 
	"gf sing", 
	"Hey!", 
	"No Animation", 
	"alt anim",
	"Echo Note",
	"Hurt Note"
];

@onready var noteVal1Text = $"chart_UI/chart_objs/chartTab/eventsWindow/value 1_text";
@onready var noteVal2Text = $"chart_UI/chart_objs/chartTab/eventsWindow/value 2_text";
@onready var currentNoteSelected = $chart_UI/chart_objs/chartTab/notesWindow/note_type;
@onready var notesEvents = $chart_UI/chart_objs/chartTab/eventsWindow/note_events;

var events = {
	"": "",
	"add cam zoom": "Value 1 = zoom value",
	"change character": "Value1 = character (0 = bf, 1 = dad, 2 = gf)\nValue2 = new character",
	"change bg": "Value1 = new Bg name",
	"play anim": "Value1 = character (0 = bf, 1 = dad, 2 = gf)\nValue2 = anim to play",
	"flash": "Value1 = flash speed\nValue2 = flash color (in hexa code)",
	#"set camera position": "Value1 = new camera position\n(example: 20(x), 20(y))\nValue2 = just for one section? (true or false)",
	#"spawn popUp": "nothing special",
	"change song pitch": "Value 1 = new song pitch\nValue2 = instant change? (true or false)",
	"change song speed": "Value 1 = new song speed\nValue2 = instant change? (true or false)",
	"set lyric": "Value 1 = Your Lyric Text \n(use :: if you want to split the text)\nValue 2 = steps (example: 10, 20, 30, 40...)"
};

var singAnims = [
	"singLeft",
	"singDown",
	"singUp",
	"singRight"
];

var grid_size = 40;

var free_Mouse = false;
var duet_notes = false;

var curSection = 0;
var is_playing = true;

var curSong = "";
var curStage = "stage";
var songDiff = "";

var characterList = [];
var stageList = [];

var pointer_starter = Vector2.ZERO;

var chartBpm = 100;
var chartCrochet = (60.0 / chartBpm) * 1000.0;
var chartStepCrochet = chartCrochet / 4;

func get_characters():
	var charList = [];
	for i in Global.get_folder("assets/data/characters/"):
		if i.to_lower().contains("dead"):
			continue;
			
		if i.ends_with(".json"):
			charList.append(i);
			
	return charList;
	
func _ready():
	song_line.position.y = grid.position.y;
	iconP1.position.y = grid.position.y-50;
	iconP2.position.y = grid.position.y-50;
	chart_cam.position.y = grid.position.y;
	chart_bg.position.y = grid.position.y;
	
	SongData.isOnChartMode = true;
	Discord.update_discord_info("chart menu", "Is in menus");
	
	%song_name.text = SongData.week_songs[0];
	songDiff = SongData.week_diffs;
	%song_difficulty.text = songDiff;
	
	pointer_starter = songPointer.position;
	
	characterList = get_characters();
	stageList = Global.get_folder("source/stages", true);
	
	for i in note_types:
		note_type_button.add_item(i);
		
	for i in events.keys():
		events_button.add_item(i);
		event_text_array.append(i);
		
	notesEvents.connect("item_selected", eventsChange);
	events_button.connect("item_selected", change_event_text);
	note_type_button.connect("item_selected", change_note_edit);
	
	for i in characterList:
		if i.contains(".json"):
			i = i.replace(".json", "");
			
		for j in [player1Options, player2Options, gfOptions]:
			j.add_item(i);
			
	for i in [player1Options, player2Options, gfOptions]:
		i.add_item("none");
		
	characterList.append("none.text");
	
	set_audio();
	
	for i in stageList:
		stageOptions.add_item(i);
		
	loadJson(%song_name.text, %song_difficulty.text, SongData.updated_chart);
	load_section();
	
	grid.GRID_SIZE = grid_size;
	grid.grid_Y_size = SongData.songSections.size();
	try_redraw(9, 45);
	
	Conductor.curBeat = 0;
	Conductor.curStep = 0;
	Conductor.lastBeat = 0;
	Conductor.lastStep = 0;
	Conductor.getSongTime = 0.0;
	
	Conductor.changeBpm(SongData.songBpm);
	Conductor.bpm = SongData.songBpm;
	
	chartBpm = SongData.songBpm;
	
	%Bpm.value = SongData.songBpm;
	%song_speed.value = SongData.songSpeed;
	%is_pixel_stage.button_pressed = SongData.isPixelStage;
	
	for i in [player1Options, player2Options, gfOptions]:
		i.connect("item_selected", change_icons);
		
	play_song();
	update_chart_status();
	
func change_event_text(_item):
	event_text.text = "Event: %s\n\n%s"%[event_text_array[events_button.selected], events[event_text_array[events_button.selected]]];
	
func change_note_edit(_item):
	match note_types[currentNoteSelected.selected]:
		"Echo Note":
			noteVal1Text.text = "many hits:";
			noteVal2Text.text = "strumTime offset:";
			
			%noteVal1.editable = true;
			%noteVal2.editable = true;
			
			%noteVal1.step = 1;
			%noteVal2.step = 0.01;
		_:
			noteVal1Text.text = "value 1:";
			noteVal2Text.text = "value 2:";
			
			%noteVal1.editable = false;
			%noteVal2.editable = false;
			
			%noteVal1.step = 1;
			%noteVal2.step = 1;
			
			%noteVal1.value = 0;
			%noteVal2.value = 0;
			
func get_icons(_char):
	var icon = {}
	var replaced = _char;
	
	if _char.contains(".json"):
		replaced = _char.replace(".json", "");
		
	var jsonFile = FileAccess.open("res://assets/data/characters/%s.json"%[replaced],FileAccess.READ);
	var jsonData = JSON.new();
	
	if jsonFile == null or replaced == "none":
		return "no_icon";
		
	jsonData.parse(jsonFile.get_as_text());
	icon = jsonData.get_data();
	jsonFile.close();
	
	return icon["HealthIcon"];
	
func change_icons(_char):
	iconP1.reload_icon(get_icons(characterList[player1Options.selected]), "idle");
	iconP2.reload_icon(get_icons(characterList[player2Options.selected]), "idle");
	
var selectionRect = Rect2();
var mouseBoxPos = Vector2.ZERO;
var isHolding = false;

func _draw() -> void:
	if !isHolding:
		return;
		
	draw_rect(selectionRect, Color(0.513, 0.908, 1.0, 0.3));
	draw_rect(selectionRect, Color(0.307, 0.711, 0.805, 0.5), false, 2.0);
	
func _input(ev):
	if ev is InputEventMouseMotion:
		if isHolding && !grab_notes && !is_playing:
			selectionRect = Rect2(
				min(mouseBoxPos.x, to_local(get_global_mouse_position()).x),
				min(mouseBoxPos.y, to_local(get_global_mouse_position()).y),
				max(mouseBoxPos.x, to_local(get_global_mouse_position()).x) - min(mouseBoxPos.x, to_local(get_global_mouse_position()).x),
				max(mouseBoxPos.y, to_local(get_global_mouse_position()).y) - min(mouseBoxPos.y, to_local(get_global_mouse_position()).y)
			);
			queue_redraw();
			
	if ev is InputEventMouseButton:
		match ev.button_index:
			MOUSE_BUTTON_LEFT:
				if ev.pressed:
					isHolding = true;
					mouseBoxPos = to_local(get_global_mouse_position());
				else:
					isHolding = false;
					selectionRect = Rect2();
					queue_redraw();
					
			MOUSE_BUTTON_WHEEL_DOWN:
				update_song(1);
				
			MOUSE_BUTTON_WHEEL_UP:
				update_song(-1);
				
	if ev is InputEventKey:
		if !ev.pressed:
			duet_notes = false;
			free_Mouse = false;
			return;
			
		if %song_name.has_focus() or %song_difficulty.has_focus() or %"value 1".has_focus() or %"value 2".has_focus():
			return;
			
		match ev.keycode:
			KEY_DELETE:
				for i in SongData.get_section_notes(curSection).size():
					for j in selected_notes:
						if j == null:
							continue;
							
						delete_note(j.strumTime + section_start_time(), j.noteData);
						selected_notes.erase(j);
						
				SongData.reload_section();
				load_section();
				
			KEY_Q:
				if !curselected_note.is_empty():
					%note_sustain_lenght.value = max(%note_sustain_lenght.value - chartStepCrochet * 0.5, 0.0);
					load_section();
					
			KEY_E:
				if !curselected_note.is_empty():
					%note_sustain_lenght.value += chartStepCrochet * 0.5;
					load_section();
					
			KEY_SHIFT:
				free_Mouse = true;
				
			KEY_CTRL:
				duet_notes = true;
				
			KEY_SPACE:
				selectionRect = Rect2();
				queue_redraw();
				play_song();
				
			KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER:
				if !ev.echo:
					Global.update_cursor("default");
					load_chart_stuff();
					
					inst.stream_paused = true;
					voices.stream_paused = true;
					
					SongData.week_songs = %song_name.text;
					SongData.week_diffs = %song_difficulty.text;
					
					var new_diff = %song_difficulty.text;
					var new_name = %song_name.text;
					
					var chart = {
						"strums": [{
							"player": SongData.playerNotes.duplicate(true),
							"opponent": SongData.opponentNotes.duplicate(true)
						}],
						"sections": SongData.songSections.duplicate(true),
						"events": SongData.songEvents.duplicate(true),
						"meta": {
							"song": SongData.song,
							"stage": SongData.stage,
							"player1": SongData.player1,
							"player2": SongData.player2,
							"gfVersion": SongData.gfPlayer,
							"needsVoices": SongData.needVoice,
							"speed": SongData.songSpeed,
							"bpm": SongData.songBpm,
							"isPixelStage": SongData.isPixelStage
						}
					};
					SongData.loadJson(new_name, new_diff, chart);
					Global.changeScene("gameplay/PlayState", true, false);
					SongData.isOnChartMode = true;
					
func mouse_inside_obj(spr, offset = 2):
	var mouse = get_global_mouse_position();
	var size = spr.sprite_frames.get_frame_texture(spr.animation, spr.frame).get_size() * spr.scale;
	if (mouse.x > spr.global_position.x - size.x / offset && mouse.x < spr.global_position.x + size.x / offset && mouse.y > spr.global_position.y - size.y / offset && mouse.y < spr.global_position.y + size.y / offset):
		return true;
		
	return false;
	
func obj_inside_block(obj, offset):
	if obj == null:
		return false;
		
	if (obj.sprite_frames if obj is AnimatedSprite2D else obj.texture) == null:
		return false;
		
	var size = (obj.sprite_frames.get_frame_texture(obj.animation, obj.frame).get_size() if obj is AnimatedSprite2D else obj.texture.get_size()) * obj.scale
	if (selectionRect.position.x + selectionRect.size.x > obj.global_position.x - size.x / offset && selectionRect.position.x < obj.global_position.x + size.x / offset  && selectionRect.position.y + selectionRect.size.y > obj.global_position.y - size.y / offset  && selectionRect.position.y < obj.global_position.y + size.y / offset):
		return true;
		
	return false;
	
func try_redraw(tileShit, songLineSize):
	grid._redraw_grid(tileShit);
	grid.queue_redraw();
	song_line.size.x = songLineSize;
	
func update_song(scroll):
	if scroll == 0:
		return;
		
	selectionRect = Rect2();
	queue_redraw();
	
	Conductor.getSongTime += 60*scroll;
	
	if curSection == 0:
		Conductor.getSongTime = max(0, Conductor.getSongTime);
		
	voices.play(Conductor.getSongTime/1000);
	inst.play(Conductor.getSongTime/1000);
	
	is_playing = false;
	inst.stream_paused = true;
	voices.stream_paused = true;
	
	var sectionLength = chartStepCrochet * SongData.songSections[curSection]["lengthInSteps"];
	match scroll:
		1:
			if number_to_time(song_line.position.y) >= sectionLength:
				changeSection(1);
		-1:
			if number_to_time(song_line.position.y) + section_start_time() < section_start_time():
				if curSection == 0:
					Conductor.getSongTime = 0;
					changeSection(0);
					return;
					
				changeSection(-1);
				
	check_song_progress();
	update_hud_position();
	
func check_song_progress():
	if floor(Conductor.getSongTime/1000) >= songLength:
		changeSection(0);
		
		Conductor.reset();
		Conductor.changeBpm(SongData.songBpm);
		Conductor.bpm = SongData.songBpm;
		
		inst.play(0.0);
		voices.play(0.0);
		
func update_selected_notes():
	for i in arrayNotes:
		if i == null:
			continue;
			
		if obj_inside_block(i.note, 8):
			if selected_notes.has(i):
				continue;
				
			i.modulate = Color(0.151, 0.574, 1.0, 1.0);
			selected_notes.append(i);
			
		elif !obj_inside_block(i.note, 8) && selectionRect != Rect2():
			i.modulate = Color(1.0, 1.0, 1.0, 1.0);
			selected_notes.erase(i);
			
func update_selected_events():
	for i in arrayEventNotes:
		if i == null:
			continue;
			
		if obj_inside_block(i.event_note, 8):
			i.modulate = Color(0.151, 0.574, 1.0, 1.0);
			curselected_event = [i.strumTime, i.noteData];
			
		elif !obj_inside_block(i.event_note, 8) && selectionRect != Rect2():
			i.modulate = Color(1.0, 1.0, 1.0, 1.0);
			
var last_song_seek = 0.0;
var selected_notes = [];
var grab_notes = false;
var arrayNotes = [];
var arrayEventNotes = [];

func _process(delta):
	var editing_text = (%song_name.has_focus() or %song_difficulty.has_focus() or %"value 1".has_focus() or %"value 2".has_focus());
	var dialogs_open = $FileDialog.visible or $FileDialogEvents.visible;
	var mouse_pos = get_global_mouse_position();
	
	inst.volume_db = 0.0 if !%mute_inst.button_pressed else -80.0;
	voices.volume_db = 0.0 if !%mute_vocals.button_pressed else -80.0;
	
	selection.visible = grid.mouse_inside_grid();
	
	var mouse_inside_ui = (
		get_viewport().gui_get_hovered_control() is TabBar 
		or get_viewport().gui_get_hovered_control() is SpinBox 
		or get_viewport().gui_get_hovered_control() is CheckBox 
		or get_viewport().gui_get_hovered_control() is Button 
		or get_viewport().gui_get_hovered_control() is OptionButton 
		or get_viewport().gui_get_hovered_control() is ProgressBar
		or get_viewport().gui_get_hovered_control() is Label
		or get_viewport().gui_get_hovered_control() == $chart_UI/chart_objs/topBar 
		or get_viewport().gui_get_hovered_control() == $chart_UI/chart_objs/bottomBar
		or $chart_UI/chart_objs/chartTab/helpWindow.mouse_inside
		or $chart_UI/chart_objs/chartTab/soundWindow.mouse_inside
		or $chart_UI/chart_objs/chartTab/chartWindow.mouse_inside
		or $chart_UI/chart_objs/chartTab/sectionWindow.mouse_inside
		or $chart_UI/chart_objs/chartTab/notesWindow.mouse_inside
		or $chart_UI/chart_objs/chartTab/eventsWindow.mouse_inside
		or $chart_UI/chart_objs/chartTab/opponentPreviewWindow.mouse_inside
		or $chart_UI/chart_objs/chartTab/playerPreviewWindow.mouse_inside
	);
	
	if !mouse_inside_ui && !dialogs_open:
		update_selected_notes();
		update_selected_events();
		
		if Input.is_action_just_pressed("mouse_click") && grid.mouse_inside_grid() && !grab_notes:
			var note_pos = floor(grid.get_local_mouse_position().x / grid_size);
			if note_pos > -1:
				if note_pos < 8:
					add_note(selection.position.y-20, note_pos, 0, note_types[note_type_button.selected]);
				elif note_pos >= 8:
					add_event_note(selection.position.y-20, note_pos);
					
	%add_event.disabled = curselected_event.is_empty();
	notesEvents.disabled = curselected_event.is_empty();
	
	if Input.is_action_just_pressed("copy") && !selected_notes.is_empty():
		copy_section(selected_notes);
		
	if Input.is_action_just_pressed("paste") && !copyNotes.is_empty():
		paste_section();
		
	if is_playing:
		Conductor.getSongTime += (delta*1000);
		
		if abs(inst.get_playback_position() - Conductor.getSongTime / 1000) > 0.03 && Time.get_ticks_msec() - last_song_seek > 500:
			inst.seek(Conductor.getSongTime / 1000);
			voices.seek(Conductor.getSongTime / 1000);
			last_song_seek = Time.get_ticks_msec();
			
		var sectionLength = chartStepCrochet * SongData.songSections[curSection]["lengthInSteps"];
		if Conductor.getSongTime >= section_start_time() + sectionLength:
			changeSection(1);
			
		check_song_progress();
		update_hud_position();
	else:
		if editing_text:
			return;
			
		if !dialogs_open:
			if Input.is_action_just_pressed("input_D"):
				changeSection(1);
				Conductor.getSongTime = section_start_time();
				
			if Input.is_action_just_pressed("input_A"):
				changeSection(-1);
				Conductor.getSongTime = section_start_time();
				
	if !editing_text && !dialogs_open:
		if Input.is_action_pressed("input_S"):
			update_song(1);
			
		if Input.is_action_pressed("input_W"):
			update_song(-1);
			
	if selectionRect == Rect2():
		if !grid.mouse_inside_grid():
			Global.update_cursor("pointer" if mouse_inside_ui else "default");
	else:
		Global.update_cursor("crosshair");
		
	var currentPosition = max(Conductor.getSongTime / 1000.0, 0.0);
	
	var curMinutes = str(int(currentPosition) / 60).pad_zeros(1);
	var curSeconds = str(int(currentPosition) % 60).pad_zeros(2);
	var maxMinutes = str(int(songLength) / 60).pad_zeros(1);
	var maxSeconds = str(int(songLength) % 60).pad_zeros(2);
	
	var chartCurStep = (curSection*16) + floor(number_to_time(time_to_number(Conductor.getSongTime - section_start_time())) / chartStepCrochet);
	var chartCurBeat = floor(chartCurStep / 4);
	
	chart_info.text = "Section: %s      Step: %s      Beat: %s                                                      %s        BPM: %s"%[curSection, int(chartCurStep), int(chartCurBeat), str(curMinutes, ":", curSeconds, " / ", maxMinutes, ":", maxSeconds), %Bpm.value];
	
	if grid.mouse_inside_grid():
		selection.global_position.x = grid.global_position.x + floor(grid.get_local_mouse_position().x / grid_size) * grid_size+20;
		selection.position.y = (mouse_pos.y if free_Mouse else floor(mouse_pos.y/grid_size) * grid_size)-20;
		if selectionRect == Rect2() && !mouse_inside_ui:
			Global.update_cursor("cell");
			
	timeBar.value = Conductor.getSongTime/1000;
	songPointer.position.x = lerp(pointer_starter.x, pointer_starter.x + 330, (timeBar.value / timeBar.max_value));
	
	if !is_playing:
		return;
		
	var songTime = (Conductor.getSongTime - section_start_time());
	for note in arrayNotes:
		if note == null:
			continue;
			
		var force_play = (songTime - note.strumTime >= 0 && songTime - note.strumTime < note.sustainLength) if note.sustainLength > 0 else abs(songTime - note.strumTime) <= 10;
		if force_play:
			var character = chartBf if note.chart_player else chartEnemy;
			character._playAnim(singAnims[note.noteData % 4]);
			
		if note.gotHit:
			if songTime < note.strumTime:
				note.gotHit = false;
				
		elif songTime >= note.strumTime:
			note.gotHit = true;
			
		if abs(songTime - note.strumTime) <= 10:
			if note.chart_player:
				if %player_sound_hit.button_pressed:
					Sound.add_new_sound("hitNotePlayer", Node.PROCESS_MODE_ALWAYS);
					
			elif %opponent_sound_hit.button_pressed:
				Sound.add_new_sound("hitNoteOpponent", Node.PROCESS_MODE_ALWAYS);
				
		note.modulate.a = 0.5 if note.gotHit else 1.0;
		
func changeSection(sec, lastSec = false):
	if lastSec:
		curSection = SongData.songSections.size()-1;
	elif sec == 0:
		curSection = 0;
	else:
		curSection += sec;
		
	if floor(Conductor.getSongTime / 1000) < songLength && curSection + 1 == SongData.songSections.size():
		add_null_section();
		
	curSection = wrapi(curSection, 0, SongData.songSections.size());
	
	load_section();
	update_chart_status();
	
func play_song():
	is_playing = !is_playing;
	inst.stream_paused = !is_playing;
	voices.stream_paused = !is_playing;
	
func load_section():
	chartBpm = get_section_bpm(curSection);
	chartCrochet = (60.0 / chartBpm) * 1000.0;
	chartStepCrochet = chartCrochet / 4.0;
	
	if SongData.songSections[curSection]["gfSection"]:
		if SongData.songSections[curSection]["mustHitSection"]:
			iconP1.reload_icon("gf", "idle");
		else:
			iconP2.reload_icon("gf", "idle");
			
	change_icons(0);
	
	for sec in loadSec.keys():
		unload_section(sec);
		
	for sec in range(max(curSection - 2, 0), min(curSection + 2, SongData.songSections.size() - 1) + 1):
		load_new_section(sec);
		
var loadSec = {};
func load_new_section(sec):
	if loadSec.has(sec):
		return;
		
	loadSec[sec] = {
		"notes": [],
		"event": []
	};
	
	for note_data in SongData.get_character_section_notes(sec, SongData.playerNotes):
		var strumTime = note_data[0];
		var noteTime = strumTime - section_start_time();
		
		var lane = int(note_data[1]);
		if lane < 4:
			lane += 4;
			
		var new_note = spawn_note(noteTime, lane, note_data[2], floor(time_to_number(noteTime)), note_data[3]);
		loadSec[sec]["notes"].append(new_note);
		
	for note_data in SongData.get_character_section_notes(sec, SongData.opponentNotes):
		var strumTime = note_data[0];
		var noteTime = strumTime - section_start_time();
		
		var lane = int(note_data[1]);
		if lane > 3:
			lane -= 4;
			
		var new_note = spawn_note(noteTime, lane, note_data[2], floor(time_to_number(noteTime)), note_data[3]);
		loadSec[sec]["notes"].append(new_note);
		
	for note_data in SongData.get_character_section_notes(sec, SongData.songEvents):
		var strumTime = note_data[0];
		var noteTime = strumTime - section_start_time();
		
		var new_event_note = spawn_event_note(noteTime, note_data[1], floor(time_to_number(noteTime)));
		loadSec[sec]["event"].append(new_event_note);
		
func unload_section(sec):
	if !loadSec.has(sec):
		return;
		
	for note in loadSec[sec]["notes"]:
		arrayNotes.erase(note);
		note.queue_free();
		
	for note in loadSec[sec]["event"]:
		arrayEventNotes.erase(note);
		note.queue_free();
		
	loadSec.erase(sec);
	
func spawn_note(strumtime = 0.0, noteData = 0, sustain = 0, cool_y = null, note_type = ""):
	return creat_note(false, strumtime, int(noteData), sustain, cool_y, note_type);
	
func spawn_event_note(strumtime = 0.0, noteData = 0, cool_y = null):
	return creat_note(true, strumtime, int(noteData), 0, cool_y, "");
	
var notesArray = [];
func creat_note(event_note = false, strumtime = 0.0, noteData = 0, sustain = 0, cool_y = null, note_type = ""):
	var newNote = Note.new() if !event_note else EventNote.new();
	newNote.strumTime = strumtime;
	newNote.noteData = noteData;
	newNote.sustainLength = sustain;
	newNote.isChartNote = true;
	newNote.type = note_type;
	newNote.chart_player = noteData > 3 && noteData < 8;
	newNote.position = Vector2(
		floor(noteData * grid_size) + 380, 
		grid_size + cool_y - 20 if cool_y != null else selection.position.y
	);
	notes.add_child(newNote);
	if !event_note:
		arrayNotes.append(newNote);
	else:
		arrayEventNotes.append(newNote);
		
	spawn_sustain(newNote);
	return newNote;
	
func spawn_sustain(note):
	if note.noteLine != null:
		if note.noteLine.get_point_count() == 0:
			note.noteLine.add_point(Vector2.ZERO);
			note.noteLine.add_point(Vector2.ZERO);
			
		note.noteLine.set_point_position(0, Vector2.ZERO);
		note.noteLine.set_point_position(1, Vector2(0, note.sustainLength));
		note.noteEnd.position.y = note.sustainLength;
		
func add_event_note(strumtime, noteData):
	var note_strumtime = number_to_time(strumtime) + section_start_time();
	var note_data = noteData;
	
	var new_note = [note_strumtime, note_data];
	
	var exists = false;
	
	for i in SongData.songEvents:
		if is_equal_approx(i[0], note_strumtime) && int(i[1]) == int(note_data):
			exists = true;
			
	if exists:
		delete_event_note(note_strumtime, int(note_data));
	else:
		SongData.songEvents.append(new_note);
		curselected_event = new_note;
		
	SongData.reload_section();
	load_section();
	print(curselected_event);
	
func add_note(strumtime, noteData, _sustain, type):
	var note_strumtime = number_to_time(strumtime) + section_start_time();
	var note_data = noteData;
	var note_sustain = 0;
	var note_type = type;
	
	var new_note = [note_strumtime, int(note_data)%4, note_sustain, note_type]; 
	if note_types[currentNoteSelected.selected] == "Echo Note":
		new_note.append(%noteVal1.value);
		new_note.append(%noteVal2.value);
	else:
		new_note.append(null);
		new_note.append(null);
		
	var exists = false;
	
	for i in SongData.get_note_array(noteData):
		var lane = noteData;
		if lane > 3:
			lane -= 4;
			
		if is_equal_approx(i[0], note_strumtime) && int(i[1]) == int(lane):
			exists = true;
			break;
			
	if exists:
		delete_note(note_strumtime, int(note_data));
	else:
		SongData.get_note_array(noteData).append(new_note);
		if duet_notes:
			var duet = new_note.duplicate(true);
			duet[1] = int(duet[1] + 4)%8;
			SongData.get_note_array(duet[1]).append(new_note);
			
		curselected_note = new_note;
		%note_sustain_lenght.value = curselected_note[2];
		
	SongData.reload_section();
	load_section();
	print(curselected_note);
	
func delete_note(strumtime, noteData):
	var notes_deleted = [];
	for i in SongData.get_note_array(noteData):
		var lane = noteData;
		if lane > 3:
			lane -= 4;
			
		if int(i[0]) == int(strumtime) && i[1] == int(lane):
			notes_deleted.append(i);
			if i == curselected_note:
				curselected_note = [];
				
	for i in notes_deleted:
		SongData.get_note_array(noteData).erase(i);
		
func delete_event_note(strumtime, noteData):
	var notes_deleted = [];
	for i in SongData.songEvents:
		if int(i[0]) == int(strumtime) && i[1] == int(noteData):
			notes_deleted.append(i);
			if i == curselected_event:
				curselected_event = [];
				
	for i in notes_deleted:
		SongData.songEvents.erase(i);
		
func loadJson(song, difficulty = "", new_chart = null):
	var difficultyPath = ("res://assets/songs/%s/chart/%s.json"%[song, song]) if difficulty == "" or difficulty == "normal" else ("res://assets/songs/%s/chart/%s-%s.json"%[song, song, difficulty]);
	var jsonFile = FileAccess.open(difficultyPath, FileAccess.READ);
	var jsonData = JSON.new();
	
	if !FileAccess.file_exists(difficultyPath):
		return;
		
	jsonData.parse(jsonFile.get_as_text());
	var data = jsonData.get_data() if new_chart == null else new_chart;
	jsonFile.close();
	
	if data.has("song"):
		SongData.convert_pyschChart(data, difficultyPath.replace(".json", "-events.json"));
	elif data.has("codenameChart"):
		SongData.convert_codenameChart(data, song, difficultyPath.replace(".json", "-events.json"));
	else:
		SongData.set_chart(data, difficultyPath.replace(".json", "-events.json"));
		
	SongData.reload_section();
	
	if SongData.stage.contains(" "):
		SongData.stage = SongData.stage.replace(" ", "_");
		
	var character_option_selected = {
		player1Options: SongData.player1,
		player2Options: SongData.player2,
		gfOptions: SongData.gfPlayer,
		stageOptions: SongData.stage
	};
	
	for opt in character_option_selected.keys():
		select_option(opt, character_option_selected[opt]);
		
	change_icons(0);
	
func select_option(curCharacterOption, curCharacter):
	if curCharacter.contains("dead") or curCharacter.contains("DEAD") or curCharacter.contains("Dead"):
		curCharacter = "none";
		
	for i in curCharacterOption.get_item_count():
		if curCharacterOption.get_item_text(i) == curCharacter:
			curCharacterOption.select(i);
		if curCharacter == null or curCharacter == "":
			curCharacterOption.select(characterList.size()-1);
			
func section_start_time(sec = curSection):
	var newPos = 0.0;
	var bpm = SongData.songBpm;
	
	for i in sec:
		if SongData.songSections[i]["changeBPM"]:
			bpm = SongData.songSections[i]["bpm"];
			
		var crochet = (60.0 / bpm) * 1000.0;
		var stepCrochet = crochet / 4.0;
		
		newPos += SongData.songSections[i]["lengthInSteps"] * stepCrochet;
		
	return newPos;
	
func get_section_bpm(sec):
	var newBpm = SongData.songBpm;
	for i in range(sec):
		if SongData.songSections[i]["changeBPM"]:
			newBpm = SongData.songSections[i]["bpm"];
			
	return newBpm;
	
func save_json(json):
	load_chart_stuff();
	for i in SongData.songEvents.size():
		if SongData.songEvents[i] == [] or SongData.songEvents[i] == null:
			SongData.songEvents = [];
			
	var chartPath = json.replace(".json", "");
	var file = FileAccess.open(chartPath + ".json", FileAccess.WRITE);
	file.store_string(JSON.stringify({
		"strums": [{
			"player": SongData.playerNotes,
			"opponent": SongData.opponentNotes
		}],
		"sections": SongData.songSections,
		"events": SongData.songEvents,
		"meta": {
			"song": SongData.song,
			"stage": SongData.stage,
			"player1": SongData.player1,
			"player2": SongData.player2,
			"gfVersion": SongData.gfPlayer,
			"needsVoices": SongData.needVoice,
			"speed": SongData.songSpeed,
			"bpm": SongData.songBpm,
			"isPixelStage": SongData.isPixelStage
		}
	}, "\t"));
	file.close();
	
func _on_file_dialog_events_file_selected(path):
	if !SongData.songEvents.is_empty():
		var file = FileAccess.open(path, FileAccess.WRITE);
		file.store_string(JSON.stringify({
			"song": {
				"events": SongData.songEvents
			}
		}, "\t"));
		file.close();
		
func load_chart_stuff():
	load_selected_option(player1Options, characterList, "player1");
	load_selected_option(player2Options, characterList, "player2");
	load_selected_option(gfOptions, characterList, "gfVersion");
	load_selected_option(stageOptions, stageList, "stage");
	
	SongData.needVoice = %have_voice_track.button_pressed;
	SongData.isPixelStage = %is_pixel_stage.button_pressed;
	SongData.songSpeed = %song_speed.value;
	SongData.songBpm = %Bpm.value;
	
func update_chart_status():
	%must_hit.button_pressed = SongData.songSections[curSection]["mustHitSection"];
	%gf_section.button_pressed = SongData.songSections[curSection]["gfSection"];
	%alt_section.button_pressed = SongData.songSections[curSection]["altAnim"];
	%bpm_change.button_pressed = SongData.songSections[curSection]["changeBPM"];
	if SongData.songSections[curSection]["changeBPM"]:
		%new_bpm.value = SongData.songSections[curSection]["bpm"];
		
func load_selected_option(opt, list, variable):
	match variable:
		"player1": SongData.player1 = list[opt.selected].substr(0, list[opt.selected].length() - 5);
		"player2": SongData.player2 = list[opt.selected].substr(0, list[opt.selected].length() - 5);
		"gfVersion": SongData.gfPlayer = list[opt.selected].substr(0, list[opt.selected].length() - 5);
		"stage": SongData.stage = list[opt.selected];
		
var copyNotes = [];
var copySection = 0;
func copy_section(cool_array):
	copyNotes = [];
	copySection = curSection;
	for i in cool_array:
		if i == null:
			continue;
			
		copyNotes.append([i.strumTime, i.noteData, i.sustainLength, i.type]);
		
func paste_section():
	if copyNotes == []:
		return;
		
	for i in copyNotes:
		var note = i.duplicate();
		note.append(null);
		note.append(null);
		
		note[0] += section_start_time();
		
		var lane = note[1];
		
		match grid.get_side():
			0:
				if lane >= 4:
					lane = abs(int(lane-4));
			1:
				if lane < 4:
					lane = int(lane+4)%8;
					
		var noteArray = SongData.get_note_array(lane);
		if noteArray.has(note):
			continue;
			
		note[1] = int(note[1])%4;
		noteArray.append(note);
		
	SongData.reload_section();
	load_section();
	
func set_audio():
	var diffPrexif = str("-remix" if %song_difficulty.text.to_lower() == "-remix" or %song_difficulty.text.to_lower() == "remix" else "");
	var music_inst = load("res://assets/songs/%s/song/Inst%s.ogg"%[%song_name.text.to_lower(), diffPrexif]);
	
	var music_voices = "res://assets/songs/%s/song/Voices%s.ogg"%[%song_name.text.to_lower(), diffPrexif];
	var music_voices_player = "res://assets/songs/%s/song/Voices-player%s.ogg"%[%song_name.text.to_lower(), diffPrexif];
	var music_voices_opponent = "res://assets/songs/%s/song/Voices-opponent%s.ogg"%[%song_name.text.to_lower(), diffPrexif];
	
	var vocalsSynchronized = AudioStreamSynchronized.new();
	
	if ResourceLoader.exists(music_voices_player) && ResourceLoader.exists(music_voices_player):
		vocalsSynchronized.stream_count = 2;
		vocalsSynchronized.set_sync_stream(0, load(music_voices_player));
		vocalsSynchronized.set_sync_stream(1, load(music_voices_opponent));
	else:
		vocalsSynchronized.stream_count = 1;
		vocalsSynchronized.set_sync_stream(0, load(music_voices));
		
	inst.stream = music_inst;
	voices.stream = vocalsSynchronized;
	
	inst.play(0.0);
	voices.play(0.0);
	
	inst.stream_paused = true;
	voices.stream_paused = true;
	
	var instLength = music_inst.get_length();
	var vocalsLength = vocalsSynchronized.get_sync_stream(0).get_length();
	
	songLength = max(instLength, vocalsLength);
	
	timeBar.max_value = songLength;
	
func _on_must_hit_pressed():
	SongData.songSections[curSection]["mustHitSection"] = %must_hit.button_pressed;
	load_section();
	
func _on_gf_section_pressed():
	SongData.songSections[curSection]["gfSection"] = %gf_section.button_pressed;
	load_section();
	
func _on_alt_section_pressed():
	SongData.songSections[curSection]["altAnim"] = %alt_section.button_pressed;
	load_section();
	
func _on_bpm_change_pressed():
	SongData.songSections[curSection]["changeBPM"] = %bpm_change.button_pressed;
	%new_bpm.editable = %bpm_change.button_pressed;
	load_section();
	
func _on_section_step_value_changed(value):
	SongData.songSections[curSection]["lengthInSteps"] = value;
	load_section();
	
func _on_new_bpm_value_changed(value):
	SongData.songSections[curSection]["bpm"] = value;
	load_section();
	
func _on_clear_section_pressed() -> void:
	SongData.clear_section(curSection);
	load_section();
	
func _on_add_section_pressed() -> void:
	add_null_section();
	
func _on_play_pressed() -> void:
	play_song();
	
func _on_previous_section_pressed() -> void:
	changeSection(-1);
	Conductor.getSongTime = section_start_time();
	
	update_hud_position();
	
func _on_next_section_pressed() -> void:
	changeSection(1);
	Conductor.getSongTime = section_start_time();
	
	update_hud_position();
	
func _on_last_section_pressed() -> void:
	changeSection(0, true);
	Conductor.getSongTime = section_start_time();
	
	update_hud_position();
	
func _on_first_section_pressed() -> void:
	changeSection(0);
	Conductor.getSongTime = section_start_time();
	
	update_hud_position();
	
func _on_note_sustain_lenght_value_changed(value: float) -> void:
	if curselected_note != []:
		curselected_note[2] = value;
		
	load_section();
	
func _on_add_event_pressed() -> void:
	if curselected_event.is_empty():
		return;
		
	notesEvents.clear();
	var found = false;
	for j in SongData.songEvents:
		if j[0] == curselected_event[0] && int(j[1]) == int(curselected_event[1]):
			if j.size() < 5:
				j.append_array([event_text_array[events_button.selected], %"value 1".text, %"value 2".text]);
				found = true;
				break;
				
	if !found:
		SongData.songEvents.append([curselected_event[0], curselected_event[1], event_text_array[events_button.selected], %"value 1".text, %"value 2".text]);
		
	for i in SongData.songEvents.size():
		if SongData.songEvents[i][0] == curselected_event[0] && int(SongData.songEvents[i][1]) == int(curselected_event[1]):
			notesEvents.add_item(SongData.songEvents[i][2]);
			notesEvents.set_item_metadata(notesEvents.item_count - 1, i);
			
var event_index = -1;
func eventsChange(index):
	event_index = notesEvents.get_item_metadata(index);
	
	events_button.select(event_text_array.find(SongData.songEvents[event_index][2]));
	%"value 1".text = SongData.songEvents[event_index][3];
	%"value 2".text = SongData.songEvents[event_index][4];
	
func _on_value_1_text_changed(new_text):
	if event_index == -1:
		return;
		
	SongData.songEvents[event_index][3] = new_text;
	
func _on_value_2_text_changed(new_text):
	if event_index == -1:
		return;
		
	SongData.songEvents[event_index][4] = new_text;
	
func add_null_section():
	SongData.songSections.append({
		"altAnim": false,
		"bpm": 0.0,
		"changeBPM": false,
		"gfSection": false,
		"lengthInSteps": 16.0,
		"mustHitSection": SongData.songSections[curSection-1]["mustHitSection"],
	});
	
func update_hud_position():
	var song_y = time_to_number(Conductor.getSongTime - section_start_time());
	for i in [song_line, chart_cam, chart_bg]:
		i.position.y = song_y;
		
	var icon_y = song_y - 50.0;
	iconP1.position.y = icon_y;
	iconP2.position.y = icon_y;
	
func number_to_time(pos_Y = 0.0):
	return remap(pos_Y, grid.position.y, grid.position.y + (16 * grid_size), 0, 16 * chartStepCrochet);
	
func time_to_number(pos = 0):
	return remap(pos, 0, 16 * chartStepCrochet, grid.position.y, grid.position.y + (16 * grid_size));
	

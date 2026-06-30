extends Node2D

var new_chartData = {};

@onready var voices = $'chart_voices';
@onready var inst = $'chart_inst';

@onready var iconP1 = $'grid_objs/icons/icon_player';
@onready var iconP2 = $'grid_objs/icons/icon_opponent';
@onready var iconP3 = $'grid_objs/icons/icon_second_opponent';

@onready var chart_cam = $'Camera2D';

@onready var event_text = $chart_UI/chart_objs/TabContainer/events/events_description;

@onready var grid = $'grid_objs/grid';
@onready var black_grid = $'grid_objs/black_grid';

@onready var song_line = $'grid_objs/song_line';
@onready var selection = $'grid_objs/selection_box';

@onready var notes = $'grid_objs/notes';
@onready var sustain_notes = $'grid_objs/sustain_notes';

@onready var player1Options = $'chart_UI/chart_objs/TabContainer/song/player1';
@onready var player2Options = $'chart_UI/chart_objs/TabContainer/song/player2';
@onready var player3Options = $'chart_UI/chart_objs/TabContainer/song/player3';
@onready var gfOptions = $'chart_UI/chart_objs/TabContainer/song/gf';
@onready var stageOptions = $'chart_UI/chart_objs/TabContainer/song/stage';

@onready var note_type_button = $'chart_UI/chart_objs/TabContainer/note/note_type';
@onready var events_button = $chart_UI/chart_objs/TabContainer/events/event;

@onready var cool_file_save = $"FileDialog";
@onready var cool_events_save = $'FileDialogEvents';

@onready var chartBf = $"chart_UI/chart_objs/TabContainer/help/preview/chart-bf";
@onready var chartEnemy = $chart_UI/chart_objs/TabContainer/help/preview/enemy_chart;

@onready var chart_info = $chart_UI/chart_objs/infos/chart_info;
@onready var timeBar = $chart_UI/chart_objs/infos/timeBar;
@onready var songPointer = $chart_UI/chart_objs/infos/songPointer;

var events_readjustment = {};
var curselected_note = [];
var curselected_event = [];

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

@onready var noteVal1Text = $chart_UI/chart_objs/TabContainer/note/val1Text;
@onready var noteVal2Text = $chart_UI/chart_objs/TabContainer/note/val2Text;
@onready var currentNoteSelected = $chart_UI/chart_objs/TabContainer/note/note_type;

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

var cursor = "";
var mouse_inside = false;
var mouse_inside_ui = false;

var gridX = null;
var gridY = null;
var grid_scaleX = null;
var grid_scaleY = null;

var grid_size = 40;

var free_Mouse = false;
var duet_notes = false;

var curSection = 0;
var is_playing = true;

var curSong = "";
var curStage = "stage";
var curDiff = "";

var is_next_section = false;

var replaceString = "";
var characterList = [];
var stageList = [];

var songDiff = "";

var add_new_tile = false;

var pointer_starter = Vector2.ZERO;

var chartBpm = 100;
var chartCrochet = (60.0 / chartBpm) * 1000.0;
var chartStepCrochet = chartCrochet / 4;

func getFolderShit(folder):
	var file = [];
	var coolFolder = DirAccess.open("res://%s"%[folder]);
	if coolFolder:
		coolFolder.list_dir_begin();
		var nameShit = coolFolder.get_next();
		while nameShit != "":
			file.append(nameShit);
			nameShit = coolFolder.get_next();
			
	return file;
	
func addCharToList():
	var charList = [];
	for i in getFolderShit("assets/data/characters/"):
		if i.to_lower().contains("dead"):
			continue;
			
		if i.ends_with(".json"):
			charList.append(i);
			
	return charList;
	
func addStagesToList():
	var newStageList = [];
	for i in getFolderShit("assets/data/stages data/"):
		if i.ends_with(".json"):
			newStageList.append(i);
			
	return newStageList;
	
func _ready():
	SongData.isOnChartMode = true;
	Discord.update_discord_info("chart menu", "Is in menus");
	
	%song_name.text = SongData.week_songs[0];
	songDiff = SongData.week_diffs;
	%song_difficulty.text = songDiff;
	
	pointer_starter = songPointer.position;
	
	characterList = addCharToList();
	stageList = addStagesToList();
	
	for i in note_types:
		note_type_button.add_item(i);
		
	for i in events.keys():
		events_button.add_item(i);
		event_text_array.append(i);
		
	events_button.connect("item_selected", change_event_text);
	note_type_button.connect("item_selected", change_note_edit);
	
	for i in characterList:
		if i.contains(".json"):
			replaceString = i.replace(".json", "");
			
		for j in [player1Options, player2Options, player3Options, gfOptions]:
			j.add_item(replaceString);
			
	for i in [player1Options, player2Options, player3Options, gfOptions]:
		i.add_item("none");
		
	characterList.append("none.text");
	
	for i in stageList:
		if i.contains(".json"):
			replaceString = i.replace(".json", "");
			
		stageOptions.add_item(replaceString);
		
	var music_path = str(%song_name.text.to_lower(), "-"+%song_difficulty.text.to_lower() if %song_difficulty.text.to_lower() == "-remix" or %song_difficulty.text.to_lower() == "remix" else "");
	var music_inst = load("res://assets/songs/" +  music_path + "/Inst.ogg");
	var music_voices = load("res://assets/songs/" +  music_path + "/Voices.ogg");
	
	inst.stream = music_inst;
	voices.stream = music_voices;
	
	inst.play(0.0);
	voices.play(0.0);
	
	inst.stream_paused = true;
	voices.stream_paused = true;
	
	timeBar.max_value = inst.stream.get_length();
	
	loadJson(%song_name.text, %song_difficulty.text, SongData.updated_chart);
	load_section();
	
	grid.GRID_SIZE = grid_size;
	grid.grid_Y_size = len(new_chartData["song"]["notes"]);
	
	black_grid.scale = Vector2(10, 16);
	black_grid.position.x = grid.position.x;
	black_grid.position.y = grid.position.y+640;
	
	Conductor.curBeat = 0;
	Conductor.curStep = 0;
	Conductor.lastBeat = 0;
	Conductor.lastStep = 0;
	Conductor.getSongTime = 0.0;
	
	Conductor.changeBpm(new_chartData["song"]["bpm"]);
	Conductor.bpm = new_chartData["song"]["bpm"];
	
	chartBpm = new_chartData["song"]["bpm"]; 
	
	%Bpm.value = Conductor.bpm;
	%song_speed.value = new_chartData["song"]["speed"];
	%is_pixel_stage.button_pressed = new_chartData["song"]["isPixelStage"];
	%new_opponent.button_pressed = new_chartData["song"]["two opponents"];
	
	for i in [player1Options, player2Options, gfOptions, player3Options]:
		i.connect("item_selected", change_icons);
		
	play_song();
	update_chart_status();
	
	if new_chartData["song"]["two opponents"]:
		try_redraw(14, 70, 14);
		events_readjustment = {
			8: 12,
			9: 13,
		};
		load_section();
		eventNote_adjustment();
	else:
		try_redraw(10, 50, 10);
		events_readjustment = {
			12: 8,
			13: 9
		};
		for i in new_chartData["song"]["notes"].size():
			var notesToDelete = new_chartData["song"]["notes"][i]["sectionNotes"];
			for j in range(notesToDelete.size()-1, -1, -1):
				if notesToDelete[j][1] >= 8:
					new_chartData["song"]["notes"][i]["sectionNotes"].remove_at(j);
					
		load_section();
		eventNote_adjustment();
		
	add_new_tile = %new_opponent.button_pressed;
	player3Options.disabled = !%new_opponent.button_pressed;
	
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
	
	if !player3Options.disabled:
		iconP3.reload_icon(get_icons(characterList[player3Options.selected]), "idle");
		
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
		if ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed:
				isHolding = true;
				mouseBoxPos = to_local(get_global_mouse_position());
			else:
				isHolding = false;
				selectionRect = Rect2();
				queue_redraw();
				
		if ev.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			update_song(1);
			
		elif ev.button_index == MOUSE_BUTTON_WHEEL_UP:
			update_song(-1);
			
	if ev is InputEventKey:
		if ev.pressed:
			if %song_name.has_focus() or %song_difficulty.has_focus() or %"value 1".has_focus() or %"value 2".has_focus():
				return;
				
			if ev.keycode in [KEY_DELETE]:
				for i in new_chartData["song"]["notes"][curSection]["sectionNotes"].size():
					for j in selected_notes:
						if j == null:
							continue;
						delete_note(j.strumTime+section_start_time(), j.noteData);
						selected_notes.erase(j);
						
				load_section();
				
			if ev.keycode in [KEY_Q] && curselected_note != []:
				%note_sustain_lenght.value = max(%note_sustain_lenght.value-chartStepCrochet/2, 0);
				load_section();
				
			if ev.keycode in [KEY_E] && curselected_note != []:
				%note_sustain_lenght.value += chartStepCrochet/2;
				load_section();
				
			if ev.keycode in [KEY_SHIFT]:
				free_Mouse = true;
				
			if ev.keycode in [KEY_CTRL]:
				duet_notes = true;
				
			if ev.keycode in [KEY_SPACE]:
				selectionRect = Rect2();
				queue_redraw();
				
				play_song();
				
			if (ev.keycode in [KEY_ESCAPE] || ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo:
				Global.update_cursor("default");
				load_chart_stuff();
				
				inst.stream_paused = true;
				voices.stream_paused = true;
				
				SongData.week_songs = %song_name.text;
				SongData.week_diffs = %song_difficulty.text;
				
				var new_chart = new_chartData;
				var new_diff = %song_difficulty.text;
				var new_name = %song_name.text;
				
				SongData.loadJson(new_name, new_diff, new_chart);
				Global.changeScene("gameplay/PlayState", true, false);
				SongData.isOnChartMode = true;
		else:
			duet_notes = false;
			free_Mouse = false;
			
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
	
func try_redraw(tileShit, songLineSize, blackGrid):
	grid._redraw_grid(tileShit);
	grid.queue_redraw();
	
	song_line.size.x = songLineSize;
	black_grid.scale.x = blackGrid;
	
func update_song(scroll):
	if scroll == 0:
		return;
		
	selectionRect = Rect2();
	queue_redraw();
	
	Conductor.getSongTime += 60*scroll;
	
	voices.play(Conductor.getSongTime/1000);
	inst.play(Conductor.getSongTime/1000);
	
	is_playing = false;
	inst.stream_paused = true;
	voices.stream_paused = true;
	
	var section_length = chartStepCrochet * new_chartData["song"]["notes"][curSection]["lengthInSteps"];
	match scroll:
		1:
			if number_to_time(song_line.position.y) >= section_length:
				changeSection(1);
		-1:
			if number_to_time(song_line.position.y) + section_start_time() < section_start_time():
				if curSection == 0:
					Conductor.getSongTime = 0;
					changeSection(0);
					return;
					
				changeSection(-1);
				
	check_song_progress();
	song_line.position.y = time_to_number(Conductor.getSongTime - section_start_time());
	chart_cam.position.y = song_line.position.y;
	$bg.position.y = song_line.position.y;
	
func check_song_progress():
	if floor(Conductor.getSongTime/1000) >= floor(inst.stream.get_length()):
		changeSection(0);
		
		Conductor.reset();
		Conductor.changeBpm(new_chartData["song"]["bpm"]);
		Conductor.bpm = new_chartData["song"]["bpm"];
		
		inst.play(0.0);
		voices.play(0.0);
		
var load_cool_section = false;
var last_tile = false;
var last_song_seek = 0.0;

var selected_notes = [];
var grab_notes = false;
var arrayNotes = [];

func _process(delta):
	var mouse_pos = get_global_mouse_position();
	
	inst.volume_db = 0.0 if !%mute_inst.button_pressed else -80.0;
	voices.volume_db = 0.0 if !%mute_vocals.button_pressed else -80.0;
	
	for note_data in new_chartData["song"]["notes"][curSection]["sectionNotes"]:
		if note_data[0] - section_start_time() >= (chartStepCrochet * new_chartData["song"]["notes"][curSection]["lengthInSteps"]):
			if new_chartData["song"]["notes"][curSection]["mustHitSection"] != new_chartData["song"]["notes"][curSection + 1]["mustHitSection"]:
				note_data[1] = int(note_data[1] + 4) % 8;
				
			new_chartData["song"]["notes"][curSection]["sectionNotes"].erase(note_data);
			new_chartData["song"]["notes"][curSection+1]["sectionNotes"].append(note_data);
			
	if add_new_tile && !load_cool_section:
		try_redraw(14, 70, 14);
		events_readjustment = {
			8: 12,
			9: 13,
		};
		eventNote_adjustment();
		load_section();
		load_cool_section = true;
		
	elif !add_new_tile && !load_cool_section:
		try_redraw(10, 50, 10);
		events_readjustment = {
			12: 8,
			13: 9
		};
		
		for i in new_chartData["song"]["notes"].size():
			var notesToDelete = new_chartData["song"]["notes"][i]["sectionNotes"];
			for j in range(notesToDelete.size()-1, -1, -1):
				if notesToDelete[j][1] >= 8:
					new_chartData["song"]["notes"][i]["sectionNotes"].remove_at(j);
					
		eventNote_adjustment();
		load_section();
		
		load_cool_section = true;
		
	if add_new_tile != last_tile:
		load_cool_section = false;
		
	last_tile = add_new_tile;
	
	if !mouse_inside_ui && !$FileDialog.visible && !$FileDialogEvents.visible:
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
				
		if Input.is_action_just_pressed("mouse_click") && mouse_inside && !grab_notes:
			var note_data = 8 if !add_new_tile else 12;
			var note_pos = floor(get_global_mouse_position().x / grid_size)-15;
			
			if note_pos != -1:
				if note_pos < note_data:
					add_note(selection.position.y-20, note_pos, 0, note_types[note_type_button.selected]);
				elif note_pos >= note_data:
					add_event_note(selection.position.y-20, note_pos, event_text_array[events_button.selected], %"value 1".text, %"value 2".text);
					
	if !selected_notes.is_empty():
		if Input.is_action_just_pressed("copy"):
			copy_section(selected_notes);
			
	if !copyNotes.is_empty():
		if Input.is_action_just_pressed("paste"):
			paste_section(mouse_pos);
			
	gridX = grid.position.x;
	gridY = grid.position.y;
	grid_scaleX = 630 if !add_new_tile else 790;
	grid_scaleY = grid_size*16;
	
	if is_playing:
		Conductor.getSongTime += (delta*1000);
		
		if abs(inst.get_playback_position() - Conductor.getSongTime / 1000) > 0.03 && Time.get_ticks_msec() - last_song_seek > 500:
			for i in [inst, voices]:
				i.seek(Conductor.getSongTime/1000);
			last_song_seek = Time.get_ticks_msec();
			
		var section_length = chartStepCrochet * new_chartData["song"]["notes"][curSection]["lengthInSteps"];
		if Conductor.getSongTime >= section_start_time() + section_length:
			changeSection(1);
			
		check_song_progress();
		
		song_line.position.y = time_to_number(Conductor.getSongTime - section_start_time());
		chart_cam.position.y = song_line.position.y;
		$bg.position.y = song_line.position.y;
	else:
		if %song_name.has_focus() or %song_difficulty.has_focus() or %"value 1".has_focus() or %"value 2".has_focus():
			return;
			
		if !$FileDialog.visible && !$FileDialogEvents.visible:
			if Input.is_action_just_pressed("input_D"):
				changeSection(1);
				Conductor.getSongTime = section_start_time();
				
			if Input.is_action_just_pressed("input_A"):
				changeSection(-1);
				Conductor.getSongTime = section_start_time();
				
	if !(%song_name.has_focus() or %song_difficulty.has_focus() or %"value 1".has_focus() or %"value 2".has_focus()):
		if !$FileDialog.visible && !$FileDialogEvents.visible:
			if Input.is_action_pressed("input_S"):
				update_song(1);
				
			if Input.is_action_pressed("input_W"):
				update_song(-1);
				
	mouse_inside = true if mouse_pos.x >= gridX+220 && mouse_pos.x <= gridX+grid_scaleX && mouse_pos.y > gridY && mouse_pos.y < gridY + grid_scaleY else false;
	mouse_inside_ui = get_viewport().gui_get_hovered_control() is TabBar or get_viewport().gui_get_hovered_control() is SpinBox or get_viewport().gui_get_hovered_control() is CheckBox or get_viewport().gui_get_hovered_control() is Button or get_viewport().gui_get_hovered_control() is OptionButton;
	if !mouse_inside:
		Global.update_cursor("pointer" if mouse_inside_ui else "default");
		
	var curMinute = str(int(inst.get_playback_position()) / 60).pad_zeros(1);
	var curSeconds = str(int(inst.get_playback_position()) % 60).pad_zeros(2);
	var maxMinutes = str(int(inst.stream.get_length()) / 60).pad_zeros(1);
	var maxSeconds = str(int(inst.stream.get_length()) % 60).pad_zeros(2);
	
	var chartCurStep = (curSection*16) + floor(number_to_time(time_to_number(Conductor.getSongTime - section_start_time())) / chartStepCrochet);
	var chartCurBeat = floor(chartCurStep / 4);
	
	chart_info.text = str(curMinute, ":", curSeconds, " / ", maxMinutes, ":", maxSeconds) + "\nSection: %s - Step: %s - Beat: %s"%[curSection, int(chartCurStep), int(chartCurBeat)];
	
	for note in arrayNotes:
		if note == null or !is_playing:
			for i in [chartBf, chartEnemy]:
				i.goToIdle = true;
				
			continue;
			
		if note.gotHit:
			if note.strumTime > Conductor.getSongTime-section_start_time():
				note.gotHit = false;
		else:
			if note.strumTime <= Conductor.getSongTime-section_start_time():
				note.gotHit = true;
				
				if note.chart_player:
					chartBf.play_cool_anim(note.noteData);
					if %player_sound_hit.button_pressed:
						Sound.add_new_sound("hitNotePlayer", Node.PROCESS_MODE_ALWAYS);
				else:
					chartEnemy.play_cool_anim(note.noteData);
					if %opponent_sound_hit.button_pressed:
						Sound.add_new_sound("hitNoteOpponent", Node.PROCESS_MODE_ALWAYS);
						
				if note.noteData > 7 && %new_opponent.button_pressed && %opponent_sound_hit.button_pressed:
					Sound.add_new_sound("hitNoteOpponent", Node.PROCESS_MODE_ALWAYS);
					
		for i in [chartBf, chartEnemy]:
			i.goToIdle = (note.strumTime+note.sustainLength <= Conductor.getSongTime-section_start_time()) if note.sustainLength > 0.0 else true;
			
		note.modulate.a = 0.5 if note.gotHit else 1.0;
		
	if mouse_pos.x >= gridX+250 && mouse_pos.x <= gridX+grid_scaleX && mouse_pos.y > gridY && mouse_pos.y < gridY + grid_size+585:
		selection.show();
		selection.position.x = floor(mouse_pos.x/grid_size)*grid_size-220;
		selection.position.y = mouse_pos.y if free_Mouse else floor(mouse_pos.y/grid_size)*grid_size+20;
		Global.update_cursor("cell");
	else:
		selection.hide();
		
	timeBar.value = Conductor.getSongTime/1000;
	songPointer.position.x = lerp(pointer_starter.x, pointer_starter.x + 330, (timeBar.value / timeBar.max_value));
	
func changeSection(sec):
	if sec == 0:
		curSection = 0;
	else:
		curSection += sec;
		
	if floor(Conductor.getSongTime/1000) < floor(inst.stream.get_length()) && curSection+1 == len(new_chartData["song"]["notes"]):
		add_null_section();
		
	curSection = wrapi(curSection, 0, len(new_chartData["song"]["notes"]));
	
	load_section();
	update_chart_status();
	
func play_song():
	is_playing = !is_playing;
	inst.stream_paused = !is_playing;
	voices.stream_paused = !is_playing;
	
func load_section():
	for i in notes.get_children():
		i.queue_free();
		
	for i in sustain_notes.get_children():
		i.queue_free();
		
	var coolBpm = new_chartData["song"]["bpm"];
	
	for i in range(curSection + 1):
		if new_chartData["song"]["notes"][i]["changeBPM"]:
			coolBpm = new_chartData["song"]["notes"][i]["bpm"];
			
	chartBpm = coolBpm;
	chartCrochet = (60.0 / chartBpm) * 1000.0;
	chartStepCrochet = chartCrochet / 4.0;
	
	iconP1.flip_h = !new_chartData["song"]["notes"][curSection]["mustHitSection"];
	iconP2.flip_h = new_chartData["song"]["notes"][curSection]["mustHitSection"];
	
	iconP1.position.x = 430 if new_chartData["song"]["notes"][curSection]["mustHitSection"] else 610;
	iconP2.position.x = 610 if new_chartData["song"]["notes"][curSection]["mustHitSection"] else 430;
	
	if new_chartData["song"]["notes"][curSection]["gfSection"]:
		if new_chartData["song"]["notes"][curSection]["mustHitSection"]:
			iconP1.reload_icon("gf", "idle");
		else:
			iconP2.reload_icon("gf", "idle");
			
	change_icons(0);
	
	for note_data in new_chartData["song"]["notes"][curSection]["sectionNotes"]:
		var strumTime = note_data[0];
		var noteTime = strumTime - section_start_time();
		
		if noteTime >= chartStepCrochet * new_chartData["song"]["notes"][curSection]["lengthInSteps"]:
			continue;
			
		var new_note = spawn_note(noteTime, note_data[1], note_data[2], floor(time_to_number(noteTime)), note_data[3], new_chartData["song"]["notes"][curSection]["mustHitSection"]);
		new_note.noteLine.hide();
		new_note.noteEnd.hide();
		spawn_sustain(new_note);
		
	for note_data in new_chartData["song"]["events"]:
		var strumTime = note_data[0];
		var noteTime = strumTime - section_start_time();
		spawn_event_note(noteTime, note_data[1], floor(time_to_number(noteTime)));
		
func spawn_note(strumtime = 0.0, noteData = 0, sustain = 0, cool_y = null, note_type = "", isPlayeNote = false):
	return creat_note(false, strumtime, int(noteData), sustain, cool_y, note_type, isPlayeNote);
	
func spawn_event_note(strumtime = 0.0, noteData = 0, cool_y = null):
	return creat_note(true, strumtime, int(noteData), 0, cool_y, "");
	
var notesArray = [];
func creat_note(event_note = false, strumtime = 0.0, noteData = 0, sustain = 0, cool_y = null, note_type = "", isPlayeNote = false):
	var is_a_player_note = isPlayeNote;
	if noteData > 3 && noteData < 8:
		is_a_player_note = !isPlayeNote;
		
	var newNote = Note.new() if !event_note else EventNote.new();
	newNote.strumTime = strumtime;
	newNote.noteData = noteData;
	newNote.sustainLength = sustain;
	newNote.isChartNote = true;
	newNote.type = note_type;
	newNote.chart_player = is_a_player_note;
	newNote.position = Vector2(
		floor(noteData * grid_size) + 380, 
		grid_size + cool_y - 20 if cool_y != null else selection.position.y
	);
	notes.add_child(newNote);
	arrayNotes.append(newNote);
	
	return newNote;
	
func spawn_sustain(note):
	var sustain_line = $"grid_objs/note_sustain".duplicate();
	sustain_line.position = Vector2(
		note.position.x -5,
		note.position.y + grid_size / 2
	);
	sustain_line.size.y = floor(remap(note.sustainLength, 0, chartStepCrochet * 16, 0, (16 * grid_size)));
	sustain_line.show();
	sustain_notes.add_child(sustain_line);
	
	return sustain_line;
	
func add_event_note(strumtime, noteData, event, value1, value2):
	var note_strumtime = number_to_time(strumtime) + section_start_time();
	var note_data = noteData;
	var note_event = event;
	var note_value1 = value1;
	var note_value2 = value2;
	
	var new_note = [note_strumtime, note_data, note_event, note_value1, note_value2];
	var exists = false;
	
	for i in new_chartData["song"]["events"]:
		if i[0] == note_strumtime && int(i[1]) == int(note_data):
			exists = true;
			
	if exists:
		delete_event_note(note_strumtime, int(note_data));
		
	else:
		new_chartData["song"]["events"].append(new_note);
		curselected_event = new_note;
		
		spawn_event_note(note_strumtime, int(note_data), null);
		
	load_section();
	print(curselected_event);
	
func add_note(strumtime, noteData, _sustain, type):
	var note_strumtime = number_to_time(strumtime) + section_start_time();
	var note_data = noteData;
	var note_sustain = 0;
	var note_type = type;
	
	var new_note = [note_strumtime, note_data, note_sustain, note_type]; 
	if note_types[currentNoteSelected.selected] == "Echo Note":
		new_note.append(%noteVal1.value);
		new_note.append(%noteVal2.value);
		
	var exists = false;
	
	for i in new_chartData["song"]["notes"][curSection]["sectionNotes"]:
		if i[0] == note_strumtime && int(i[1]) == int(note_data):
			exists = true;
			
	if exists:
		delete_note(note_strumtime, int(note_data));
	else:
		new_chartData["song"]["notes"][curSection]["sectionNotes"].append(new_note);
		if duet_notes:
			new_chartData["song"]["notes"][curSection]["sectionNotes"].append([note_strumtime, int(noteData + 4)%8, note_sustain, note_type]);
			if note_types[currentNoteSelected.selected] == "Echo Note":
				new_chartData["song"]["notes"][curSection]["sectionNotes"].append(%noteVal1.value);
				new_chartData["song"]["notes"][curSection]["sectionNotes"].append(%noteVal2.value);
				
		curselected_note = new_note;
		%note_sustain_lenght.value = curselected_note[2];
		
		spawn_note(note_strumtime, int(note_data), note_sustain, null, note_type);
		
	load_section();
	print(curselected_note);
	
func delete_note(strumtime, noteData):
	var notes_deleted = [];
	for i in new_chartData["song"]["notes"][curSection]["sectionNotes"]:
		if int(i[0]) == int(strumtime) && i[1] == int(noteData):
			notes_deleted.append(i);
			if i == curselected_note:
				curselected_note = [];
				
	for i in notes_deleted:
		new_chartData["song"]["notes"][curSection]["sectionNotes"].erase(i);
		
func delete_event_note(strumtime, noteData):
	var notes_deleted = [];
	for i in new_chartData["song"]["events"]:
		if int(i[0]) == int(strumtime) && i[1] == int(noteData):
			notes_deleted.append(i);
			if i == curselected_event:
				curselected_event = [];
				
	for i in notes_deleted:
		new_chartData["song"]["events"].erase(i);
		
func loadJson(song, difficulty = "", mew_chart = null):
	var difficultyPath = ("res://assets/data/songs/%s/%s.json"%[song, song] if difficulty == "" or difficulty == "normal" else "res://assets/data/songs/%s/%s-%s.json"%[song, song, difficulty]);
	var jsonFile = FileAccess.open(difficultyPath, FileAccess.READ);
	var jsonData = JSON.new();
	
	if !FileAccess.file_exists(difficultyPath):
		return;
		
	jsonData.parse(jsonFile.get_as_text());
	new_chartData = jsonData.get_data() if mew_chart == null else mew_chart;
	jsonFile.close();
	
	var null_vars = {"events": [], "speed": 1.0, "bpm": 100, "two opponents": false, "player3": "none", "stage": "stage", "song": "bopeebo", "isPixelStage": false,};
	var sections_null_vars = {"altAnim": false, "bpm": 0.0, "changeBPM": false, "gfSection": false, "lengthInSteps": 16.0, "mustHitSection": true, "sectionNotes": []};
	
	if new_chartData["song"]["stage"].contains(" "):
		new_chartData["song"]["stage"] = new_chartData["song"]["stage"].replace(" ", "_");
		
	var character_option_selected = {
		player1Options: new_chartData["song"]["player1"],
		player2Options: new_chartData["song"]["player2"],
		gfOptions: new_chartData["song"]["gfVersion"],
		stageOptions: new_chartData["song"]["stage"]
	};
	
	for i in null_vars.keys():
		set_null_var(i, null_vars[i]);
		
	for i in sections_null_vars.keys():
		set_section_null_var(i, sections_null_vars[i]);
		
	for i in character_option_selected.keys():
		select_option(i, character_option_selected[i]);
		
	select_option(player3Options, new_chartData["song"]["player3"] if new_chartData["song"].has("player3") && new_chartData["song"]["player3"] != "" else null);
	
	if typeof(new_chartData["song"]["events"]) == TYPE_DICTIONARY:
		new_chartData["song"]["events"] = [];
		
	for i in new_chartData["song"]["notes"].size():
		for j in new_chartData["song"]["notes"][i]["sectionNotes"].size():
			if new_chartData["song"]["notes"][i]["sectionNotes"][j].size() < 4:
				new_chartData["song"]["notes"][i]["sectionNotes"][j].append("");
				
	change_icons(0);
	
func set_section_null_var(cool_var, new_value):
	for i in new_chartData["song"]["notes"]:
		if !i.has(cool_var):
			i[cool_var] = new_value;
			
func set_null_var(cool_var, new_value):
	if !new_chartData["song"].has(cool_var):
		new_chartData["song"][cool_var] = new_value;
		
func select_option(curCharacterOption, curCharacter):
	if curCharacter.contains("dead") or curCharacter.contains("DEAD") or curCharacter.contains("Dead"):
		curCharacter = "none";
		
	for i in curCharacterOption.get_item_count():
		if curCharacterOption.get_item_text(i) == curCharacter:
			curCharacterOption.select(i);
			
		if curCharacter == null or curCharacter == "":
			curCharacterOption.select(characterList.size()-1);
			
func eventNote_adjustment():
	if new_chartData["song"]["events"] != [] && !new_chartData["song"]["events"].is_empty():
		for i in new_chartData["song"]["events"].size():
			var note = new_chartData["song"]["events"][i];
			if int(note[1]) in events_readjustment:
				note[1] = events_readjustment[int(note[1])];
				new_chartData["song"]["events"][i] = note;
				
func section_start_time():
	var coolBpm = %Bpm.value;
	var coolPos = 0;
	
	for i in curSection:
		if new_chartData["song"]["notes"][i]["changeBPM"]:
			coolBpm = new_chartData["song"]["notes"][i]["bpm"];
			
		coolPos += 4 * (1000 * 60 / coolBpm);
		
	return coolPos;
	
func save_json(json):
	load_chart_stuff();
	for i in new_chartData["song"]["events"].size():
		if new_chartData["song"]["events"][i] == [] or new_chartData["song"]["events"][i] == null:
			new_chartData["song"]["events"] = [];
			
	var new_jsonFile = FileAccess.open(json, FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(
	{
		"song": new_chartData["song"]
	}, "\t"));
	new_jsonFile.close();
	print('save: ', json);
	
func _on_file_dialog_events_file_selected(path):
	if new_chartData["song"]["events"] != [] or !new_chartData["song"]["events"].is_empty():
		var new_eventsFile = FileAccess.open(path, FileAccess.WRITE);
		new_eventsFile.store_string(JSON.stringify(
		{
			"song": {
				"events": new_chartData["song"]["events"]
			}
		}, "\t"));
		new_eventsFile.close();
		print('save: ', path);
		
func save_file():
	cool_file_save.popup_centered();
	
func _on_save_events_json_pressed():
	cool_events_save.popup_centered();
	
func load_song_json():
	loadJson(%song_name.text, %song_difficulty.text);
	
	%Bpm.value = Conductor.bpm;
	%new_opponent.button_pressed = new_chartData["song"]["two opponents"];
	%is_pixel_stage.button_pressed = new_chartData["song"]["isPixelStage"];
	%song_speed.value = new_chartData["song"]["speed"];
	
	changeSection(0);
	Conductor.reset();
	Conductor.changeBpm(new_chartData["song"]["bpm"]);
	
	load_section();
	
	is_playing = false;
	
	var music_path = str(%song_name.text.to_lower(), "-"+%song_difficulty.text.to_lower() if %song_difficulty.text.to_lower() == "-remix" or %song_difficulty.text.to_lower() == "remix" else "");
	var music_inst = load("res://assets/songs/" +  music_path + "/Inst.ogg");
	var music_voices = load("res://assets/songs/" +  music_path + "/Voices.ogg");
	
	inst.stream = music_inst;
	voices.stream = music_voices;
	
	inst.play(0.0);
	voices.play(0.0);
	
	inst.stream_paused = true;
	voices.stream_paused = true;
	
	timeBar.max_value = inst.stream.get_length();
	
func load_chart_stuff():
	load_selected_option(player1Options, characterList, "player1");
	load_selected_option(player2Options, characterList, "player2");
	load_selected_option(gfOptions, characterList, "gfVersion");
	load_selected_option(player3Options, characterList, "player3");
	load_selected_option(stageOptions, stageList, "stage");
	
	new_chartData["song"]["needsVoices"] = %have_voice_track.button_pressed;
	new_chartData["song"]["isPixelStage"] = %is_pixel_stage.button_pressed;
	new_chartData["song"]["speed"] = %song_speed.value;
	new_chartData["song"]["bpm"] = %Bpm.value;
	new_chartData["song"]["two opponents"] = %new_opponent.button_pressed;
	
func update_chart_status():
	%must_hit.button_pressed = new_chartData["song"]["notes"][curSection]["mustHitSection"];
	%gf_section.button_pressed = new_chartData["song"]["notes"][curSection]["gfSection"];
	%alt_section.button_pressed = new_chartData["song"]["notes"][curSection]["altAnim"];
	%bpm_change.button_pressed = new_chartData["song"]["notes"][curSection]["changeBPM"];
	
func load_selected_option(opt, list, player):
	new_chartData["song"][player] = list[opt.selected].substr(0, list[opt.selected].length()-5);
	
var copyNotes = [];
var copySection = 0;
func copy_section(cool_array):
	copyNotes = [];
	copySection = curSection;
	for i in cool_array:
		if i == null:
			continue;
			
		copyNotes.append([i.strumTime, i.noteData, i.sustainLength, i.type]);
		
func paste_section(mouse_pos):
	if copyNotes == []:
		return;
		
	for i in copyNotes:
		var note = i.duplicate();
		note[0] += section_start_time();
		
		if mouse_pos.x >= 760 && mouse_pos.x < 920 && note[1] < 4:
			note[1] = int(note[1]+4)%8;
			
		elif mouse_pos.x < 760 && note[1] >= 4:
			note[1] = abs(int(note[1]-4));
			
		elif mouse_pos.x >= 920 && note[1] < 8 && %new_opponent.button_pressed:
			var val = 4 if note[1] >= 4 else 8;
			note[1] = int(note[1]+val)%12;
			
		if new_chartData["song"]["notes"][curSection]["sectionNotes"].has(note):
			continue;
			
		new_chartData["song"]["notes"][curSection]["sectionNotes"].append(note);
		
	load_section();
	
func _on_must_hit_pressed() -> void:
	new_chartData["song"]["notes"][curSection]["mustHitSection"] = %must_hit.button_pressed;
	load_section();
	
func _on_gf_section_pressed() -> void:
	new_chartData["song"]["notes"][curSection]["gfSection"] = %gf_section.button_pressed;
	load_section();
	
func _on_alt_section_pressed() -> void:
	new_chartData["song"]["notes"][curSection]["altAnim"] = %alt_section.button_pressed;
	load_section();
	
func _on_bpm_change_pressed() -> void:
	new_chartData["song"]["notes"][curSection]["changeBPM"] = %bpm_change.button_pressed;
	%new_bpm.editable =  %bpm_change.button_pressed;
	load_section();
	
func _on_section_step_value_changed(value: float) -> void:
	%section_step.value = new_chartData["song"]["notes"][curSection]["lengthInSteps"]
	load_section();
	
func _on_new_bpm_value_changed(value: float) -> void:
	new_chartData["song"]["notes"][curSection]["bpm"] = value;
	load_section();
	
func _on_clear_section_pressed() -> void:
	new_chartData["song"]["notes"][curSection]["sectionNotes"] = [];
	load_section();
	
func _on_add_section_pressed() -> void:
	add_null_section();
	
func _on_note_sustain_lenght_value_changed(value: float) -> void:
	if curselected_note != []:
		curselected_note[2] = value;
		
	load_section();
	
func _on_new_opponent_toggled(toggled_on: bool) -> void:
	iconP3.visible = toggled_on;
	player3Options.disabled = !toggled_on;
	add_new_tile = toggled_on;
	
func add_null_section():
	new_chartData["song"]["notes"].append({
		"altAnim": false,
		"bpm": 0.0,
		"changeBPM": false,
		"gfSection": false,
		"lengthInSteps": 16.0,
		"mustHitSection": new_chartData["song"]["notes"][curSection-1]["mustHitSection"],
		"sectionNotes": []
	});
	
func number_to_time(pos_Y = 0.0):
	return remap(pos_Y, grid.position.y, grid.position.y + (16 * grid_size), 0, 16 * chartStepCrochet);
	
func time_to_number(pos = 0):
	return remap(pos, 0, 16 * chartStepCrochet, grid.position.y, grid.position.y + (16 * grid_size));

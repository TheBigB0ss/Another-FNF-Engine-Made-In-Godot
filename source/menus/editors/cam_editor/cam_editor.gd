extends Node2D

@onready var stageGrp = $stage;

var bf = Character.new();
var gf = Character.new();
var dad = Character.new();

@onready var voices = $'chart_voices';
@onready var inst = $'chart_inst';

var songLength = 0.0;

var timeline_width = 0.0;
var isPlaying = false;

enum TRACK_ID{
	CAMERA = 0,
	ZOOM = 1,
	INVALID = 2
};
var curTrack = TRACK_ID.INVALID;

var camera_events = [];
var zoom_events = [];

var camsEventsToDelete = [];
var zoomsEventsToDelete = [];

var camsArray = [];
var zoomsArray = [];

@onready var camEaseOpts = $CanvasLayer/TabContainer/cam_settings/ease_options;
@onready var zoomEaseOpts = $CanvasLayer/TabContainer/zoom_settings/ease_options;

@onready var timeLine = $CanvasLayer/timeLine;
@onready var selectionBox = $CanvasLayer/selectionBox;
@onready var positionCross = $cross;

@onready var camGrp = $CanvasLayer/timeLine/cam_events;
@onready var zoomGrp = $CanvasLayer/timeLine/zoom_events;

@onready var camera = $Camera2D;

@onready var timeBar = $CanvasLayer/infos/timeBar;
@onready var songPointer = $CanvasLayer/infos/songPointer;
@onready var chart_info = $CanvasLayer/infos/timeText;

@onready var events = $EventLoader;

var pointer_starter = Vector2.ZERO;

var curselected_cam_event = null;
var curselected_zoom_event = null;

func _ready() -> void:
	MusicManager.stop();
	Discord.update_discord_info("camera editor", "Is in menus");
	
	Conductor.new_beat.connect(beat_hit);
	Conductor.new_step.connect(step_hit);
	
	for i in CamTween.EASES:
		camEaseOpts.add_item(i);
		zoomEaseOpts.add_item(i);
		
	if !SongData.week_songs.is_empty() && SongData.isPlaying:
		%song_name.text = SongData.week_songs[0];
		reload_scene(SongData.week_songs[0]);
		
	pointer_starter = songPointer.position;
	
func play_song():
	isPlaying = !isPlaying;
	inst.stream_paused = !isPlaying;
	voices.stream_paused = !isPlaying;
	
func delete_event(strumtime, array):
	var notes_deleted = [];
	for i in array:
		if int(i["strumTime"]) == int(strumtime):
			notes_deleted.append(i);
			
	for i in notes_deleted:
		array.erase(i);
		
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed:
			if ev.keycode in [KEY_ESCAPE]:
				Global.update_cursor("default");
				if !SongData.isPlaying:
					MusicManager._play_song("freakyMenu", "music", true);
					Global.changeScene("menus/main_menu/MainMenu", true, false);
				else:
					Global.changeScene("gameplay/PlayState", true, false);
					
			if ev.keycode == KEY_DELETE:
				for i in camsEventsToDelete:
					if i == null:
						continue;
						
					if i == curselected_cam_event:
						curselected_cam_event = null;
					delete_event(i["strumTime"], camera_events);
					
				for i in zoomsEventsToDelete:
					if i == null:
						continue;
						
					if i == curselected_zoom_event:
						curselected_zoom_event = null;
					delete_event(i["strumTime"], zoom_events);
					
				zoomsEventsToDelete.clear();
				camsEventsToDelete.clear();
				load_events();
				
			if ev.echo:
				if ev.keycode in [KEY_UP]:
					camera.offset.y -= 20;
					
				if ev.keycode in [KEY_DOWN]:
					camera.offset.y += 20;
					
				if ev.keycode in [KEY_RIGHT]:
					camera.offset.x += 20;
					
				if ev.keycode in [KEY_LEFT]:
					camera.offset.x -= 20;
					
				return;
				
			if ev.keycode in [KEY_SPACE]:
				play_song();
				
func reload_scene(songName):
	isPlaying = false;
	Conductor.getSongTime = 0;
	
	camera_events.clear();
	zoom_events.clear();
	
	SongData.loadJson(songName, "");
	
	var camPath = "res://assets/songs/%s/chart/camera_events.json"%[songName];
	if FileAccess.file_exists(camPath):
		var camFile = FileAccess.open(camPath, FileAccess.READ);
		var camJsonData = JSON.new();
		camJsonData.parse(camFile.get_as_text());
		
		camera_events = camJsonData.get_data()["camera events"];
		zoom_events = camJsonData.get_data()["zoom events"];
		
		%default_cam.button_pressed = camJsonData.get_data()["ignore default cams events"];
		%default_zoom.button_pressed = camJsonData.get_data()["ignore default zooms events"];
		
		camFile.close();
		
	var stage = load("res://source/stages/%s/%s.tscn"%[SongData.stage, SongData.stage]).instantiate();
	if stage is Stage:
		stage.init_game(self);
		
	SongData.loadStageJson(SongData.stage);
	
	bf = bf.init_character(self, SongData.player1StagePosition, SongData.player1Zindex, SongData.player1, 4);
	dad = dad.init_character(self, SongData.gfStagePosition if SongData.player2 == "gf" else SongData.player2StagePosition, SongData.player2Zindex, SongData.player2, 3);
	gf = gf.init_character(self, SongData.gfStagePosition, SongData.gfZindex, SongData.gfPlayer, 1);
	
	if bf.character != null:
		bf.character.flip_h = !bf.is_player;
	if dad.character != null:
		dad.character.flip_h = dad.is_player;
		
	if dad.is_player:
		for i in dad.camera_pos.size()-1:
			dad.camera_pos[i] *= -1;
			
	if !bf.is_player:
		for i in bf.camera_pos.size()-1:
			bf.camera_pos[i] *= -1;
			
	camera.global_position = (dad.global_position + Vector2(dad.camera_pos[0], dad.camera_pos[1]));
	positionCross.global_position = (dad.global_position + Vector2(dad.camera_pos[0], dad.camera_pos[1]));
	
	stageGrp.add_child(stage);
	
	camera.zoom = SongData.stageZoom;
	
	events.reload_events();
	load_song(songName);
	load_events();
	
func load_song(songName):
	var music_inst = load("res://assets/songs/%s/song/Inst.ogg"%[songName]);
	
	var music_voices = "res://assets/songs/%s/song/Voices.ogg"%[songName];
	var music_voices_player = "res://assets/songs/%s/song/Voices-player.ogg"%[songName];
	var music_voices_opponent = "res://assets/songs/%s/song/Voices-opponent.ogg"%[songName];
	
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
	
	timeLine.timeline_width = songLength * 100;
	timeLine.queue_redraw();
	
	timeBar.max_value = songLength;
	
func update_events_position(grp, arr):
	var id = 0;
	for i in grp.get_children():
		var event = arr[id];
		
		if i is Panel:
			i.position.x = timeLine.get_timeline_offset() + timeLine.time_to_position(event["strumTime"]);
			i.size.x = timeLine.time_to_position(event["strumTime"] + event["duration"]) - timeLine.time_to_position(event["strumTime"]);
		else:
			i.position.x = timeLine.get_timeline_offset() + timeLine.time_to_position(event["strumTime"]);
			id += 1;
			
func update_song(scroll):
	if scroll == 0:
		return;
		
	Conductor.getSongTime += 70*scroll;
	inst.play(Conductor.getSongTime/1000);
	voices.play(Conductor.getSongTime/1000);
	
	inst.stream_paused = true;
	voices.stream_paused = true;
	
	isPlaying = false;
	
var last_song_seek = 0.0;
func _process(delta: float) -> void:
	update_events_position(camGrp, camera_events);
	update_events_position(zoomGrp, zoom_events);
	
	if %default_zoom.button_pressed && SongData.stageZoom != Vector2.ZERO:
		camera.zoom = lerp(camera.zoom, SongData.stageZoom, 1.0 - exp(-8.0 * delta));
		
	if isPlaying:
		selectionBox.selectionRect = Rect2();
		Conductor.getSongTime += (delta*1000);
		camera.offset = lerp(camera.offset, Vector2.ZERO, 0.10);
		positionCross.global_position = lerp(positionCross.global_position, camera.global_position, 0.10);
		
		if abs(inst.get_playback_position() - Conductor.getSongTime / 1000) > 0.03 && Time.get_ticks_msec() - last_song_seek > 500:
			inst.seek(Conductor.getSongTime / 1000);
			voices.seek(Conductor.getSongTime / 1000);
			last_song_seek = Time.get_ticks_msec();
	else:
		if Input.is_action_pressed("mouse_click") && Input.is_action_pressed("ui_shift"):
			positionCross.global_position = get_global_mouse_position();
			%x_value.value = positionCross.global_position.x;
			%y_value.value = positionCross.global_position.y;
			
	Conductor.getSongTime = wrapi(Conductor.getSongTime, 0.0, (timeLine.timeline_width/100)*1000);
	
	timeBar.value = Conductor.getSongTime/1000;
	songPointer.position.x = lerp(pointer_starter.x, pointer_starter.x + 330, (timeBar.value / timeBar.max_value));
	
	if inst.stream != null && inst != null:
		var currentPosition = max(Conductor.getSongTime / 1000.0, 0.0);
		
		var curMinutes = str(int(currentPosition) / 60).pad_zeros(1);
		var curSeconds = str(int(currentPosition) % 60).pad_zeros(2);
		var maxMinutes = str(int(songLength) / 60).pad_zeros(1);
		var maxSeconds = str(int(songLength) % 60).pad_zeros(2);
		chart_info.text = str(curMinutes, ":", curSeconds, " / ", maxMinutes, ":", maxSeconds);
		
	match timeLine.get_track():
		0:
			curTrack = TRACK_ID.CAMERA;
		1:
			curTrack = TRACK_ID.ZOOM;
		_:
			curTrack = TRACK_ID.INVALID;
			
	if Input.is_action_just_pressed("mouse_click") && curTrack != 2 && timeLine.mouse_inside():
		match curTrack:
			0:
				curselected_cam_event = add_event(camera_events, {
					"strumTime": timeLine.position_to_time(timeLine.get_local_mouse_position().x),
					"targetX": %x_value.value,
					"targetY": %y_value.value,
					"duration": %duration.value,
					"easing": CamTween.EASES[camEaseOpts.selected]
				});
			1:
				curselected_zoom_event = add_event(zoom_events, {
					"strumTime": timeLine.position_to_time(timeLine.get_local_mouse_position().x),
					"target": %zoomValue.value,
					"duration": %zoomDuration.value,
					"easing": CamTween.EASES[zoomEaseOpts.selected]
				});
				
		load_events();
		
	if Input.is_action_pressed("input_A"):
		update_song(-1);
	if Input.is_action_pressed("input_D"):
		update_song(1);
		
	if !$FileDialog.visible:
		for i in zoomsArray:
			if i == null:
				continue;
				
			if selectionBox.obj_inside_block(i, 8):
				i.modulate = Color(0.151, 0.574, 1.0);
				if !zoomsEventsToDelete.has(i.get_meta("event")):
					zoomsEventsToDelete.append(i.get_meta("event"));
					
			elif !selectionBox.obj_inside_block(i, 8) && selectionBox.selectionRect != Rect2():
				i.modulate = Color(1.0, 1.0, 1.0, 1.0);
				zoomsEventsToDelete.erase(i.get_meta("event"));
				
		for i in camsArray:
			if i == null:
				continue;
				
			if selectionBox.obj_inside_block(i, 8):
				i.modulate = Color(0.151, 0.574, 1.0);
				if !camsEventsToDelete.has(i.get_meta("event")):
					camsEventsToDelete.append(i.get_meta("event"));
					
			elif !selectionBox.obj_inside_block(i, 8) && selectionBox.selectionRect != Rect2():
				i.modulate = Color.WHITE;
				camsEventsToDelete.erase(i.get_meta("event"));
				
	if selectionBox.selectionRect != Rect2():
		Global.update_cursor("crosshair");
	else:
		Global.update_cursor("pointer" if (curTrack != 2 && timeLine.mouse_inside()) else "default");
		
	play_character_anim(SongData.playerNotes, bf);
	play_character_anim(SongData.opponentNotes, dad);
	
	update_cam_event();
	update_zoom_event();
	
var start_zoom = Vector2.ZERO;
var start_pos = Vector2.ZERO;
func update_cam_event():
	var current_event = null;
	
	for i in camera_events:
		if i["duration"] <= 0:
			if Conductor.getSongTime >= i["strumTime"]:
				camera.global_position = Vector2(i["targetX"], i["targetY"]);
				
			continue;
			
		if Conductor.getSongTime < i["strumTime"]:
			continue;
			
		if Conductor.getSongTime >= i["strumTime"] + i["duration"]:
			continue;
			
		if current_event != i:
			current_event = i;
			start_pos = camera.global_position;
			
		var t = (Conductor.getSongTime - i["strumTime"]) / i["duration"];
		t = CamTween.ease_value(t, i["easing"]);
		
		positionCross.global_position = lerp(start_pos, Vector2(i["targetX"], i["targetY"]), t);
		camera.global_position = lerp(start_pos, Vector2(i["targetX"], i["targetY"]), t);
		
func update_zoom_event():
	var current_zoom_event = null;
	
	for i in zoom_events:
		if i["duration"] <= 0:
			if Conductor.getSongTime >= i["strumTime"]:
				camera.zoom = Vector2.ONE * i["target"];
				
			continue;
			
		if Conductor.getSongTime < i["strumTime"]:
			continue;
			
		if Conductor.getSongTime >= i["strumTime"] + i["duration"]:
			continue;
			
		if current_zoom_event != i:
			current_zoom_event = i;
			start_zoom = camera.zoom;
			
		var t = (Conductor.getSongTime - i["strumTime"]) / i["duration"];
		t = CamTween.ease_value(t, i["easing"]);
		
		camera.zoom = start_zoom.lerp(Vector2.ONE * i["target"], t);
		
func play_character_anim(arr, new_char):
	for note in arr:
		if note[2] == 0:
			if abs(Conductor.getSongTime - note[0]) <= 10:
				new_char.characterState = new_char.CHARACTER_STATES.SINGING;
				new_char._playAnim(["singLeft","singDown","singUp","singRight"][note[1]]);
		else:
			if Conductor.getSongTime >= note[0] && Conductor.getSongTime < note[0] + note[2]:
				new_char.characterState = new_char.CHARACTER_STATES.HOLDING;
				new_char._playAnim(["singLeft","singDown","singUp","singRight"][note[1]]);
				
func add_event(arr, data):
	for i in arr.size():
		if is_equal_approx(arr[i]["strumTime"], data["strumTime"]):
			arr.remove_at(i);
			return null;
			
	arr.append(data);
	return data;
	
func load_events():
	for i in zoomGrp.get_children():
		i.queue_free();
		
	for i in camGrp.get_children():
		i.queue_free();
		
	for i in camera_events:
		var camSpr = Sprite2D.new();
		camSpr.texture = preload("res://assets/images/editors/cam_editor/camera_icon.png");
		camSpr.position = Vector2(timeLine.get_timeline_offset()+timeLine.time_to_position(i["strumTime"]), timeLine.get_track_y(0));
		camSpr.set_meta("event", i);
		camSpr.scale = Vector2(0.3, 0.3);
		
		var durationBox = Panel.new();
		var style = StyleBoxFlat.new();
		style.bg_color = Color(0.34, 0.879, 1.0, 0.271);
		
		style.corner_radius_top_left = 8;
		style.corner_radius_top_right = 8;
		style.corner_radius_bottom_left = 8;
		style.corner_radius_bottom_right = 8;
		
		durationBox.add_theme_stylebox_override("panel", style);
		durationBox.size = Vector2(timeLine.time_to_position(i["duration"]), 40 * timeLine.TRACK_AMOUNT);
		durationBox.position = Vector2(timeLine.get_timeline_offset() + timeLine.time_to_position(i["strumTime"]) - 20, timeLine.get_track_y(0) - 20);
		durationBox.scale.y = 0.5;
		
		camGrp.add_child(durationBox);
		camGrp.add_child(camSpr);
		
		camsArray.append(camSpr);
		
	for i in zoom_events:
		var zoomSpr = Sprite2D.new();
		zoomSpr.texture = preload("res://assets/images/editors/cam_editor/zoom_icon.png");
		zoomSpr.position = Vector2(timeLine.get_timeline_offset()+timeLine.time_to_position(i["strumTime"]), timeLine.get_track_y(1));
		zoomSpr.set_meta("event", i);
		zoomSpr.scale = Vector2(0.3, 0.3);
		
		var durationBox = Panel.new();
		var style = StyleBoxFlat.new();
		style.bg_color = Color(0.34, 0.879, 1.0, 0.271);
		
		style.corner_radius_top_left = 8;
		style.corner_radius_top_right = 8;
		style.corner_radius_bottom_left = 8;
		style.corner_radius_bottom_right = 8;
		
		durationBox.add_theme_stylebox_override("panel", style);
		durationBox.size = Vector2(timeLine.time_to_position(i["duration"]), 40 * timeLine.TRACK_AMOUNT);
		durationBox.position = Vector2(timeLine.get_timeline_offset() + timeLine.time_to_position(i["strumTime"]) - 20, timeLine.get_track_y(1) - 20);
		durationBox.scale.y = 0.5;
		
		zoomGrp.add_child(durationBox);
		zoomGrp.add_child(zoomSpr);
		
		zoomsArray.append(zoomSpr);
		
var cam_target = null;
func step_hit(_step):
	if SongData.songSections.is_empty():
		return;
		
	if !%default_cam.button_pressed:
		return;
		
	if is_on_event(curselected_cam_event):
		return;
		
	cam_target = dad;
	if SongData.songSections[Conductor.curSection]["gfSection"]:
		cam_target = gf;
	elif SongData.songSections[Conductor.curSection]["mustHitSection"]:
		cam_target = bf;
		
	if cam_target != null:
		camera.global_position = (cam_target.global_position + Vector2(cam_target.camera_pos[0], cam_target.camera_pos[1]));
		positionCross.global_position = (cam_target.global_position + Vector2(cam_target.camera_pos[0], cam_target.camera_pos[1]));
		
func beat_hit(beat):
	if !%default_zoom.button_pressed:
		return;
		
	if beat % 4 == 0:
		camera.zoom = SongData.stageZoomBeat;
		
func is_on_event(event):
	if event == null:
		return false;
		
	if event["duration"] <= 0:
		return false;
		
	return Conductor.getSongTime >= event["strumTime"] && Conductor.getSongTime < event["strumTime"] + event["duration"];
	
func _on_load_song_pressed() -> void:
	for i in stageGrp.get_children():
		if i == null:
			continue;
			
		remove_child(i);
		i.queue_free();
		
	for i in [dad, bf, gf]:
		if i == null:
			continue;
			
		remove_child(i);
		i.queue_free();
		
	reload_scene(%song_name.text);
	
func _on_save_json_pressed() -> void:
	$FileDialog.show();
	
func _on_file_dialog_file_selected(json) -> void:
	var chartPath = json.replace(".json", "");
	var file = FileAccess.open(chartPath + ".json", FileAccess.WRITE);
	file.store_string(JSON.stringify(
		{
			"camera events": camera_events,
			"zoom events": zoom_events,
			"ignore default cams events": %default_cam.button_pressed,
			"ignore default zooms events": %default_zoom.button_pressed
		}, "\t"));
	file.close();

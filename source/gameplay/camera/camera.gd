extends Camera2D

@onready var main_scene = get_tree().current_scene;

var cameraEvents = [];
var zoomEvents = [];

var useDefaultZoomEvent = true;
var useDefaultCamsEvent = true;

var current_event = null;
var start_pos = Vector2.ZERO;

var current_zoom_event = null;
var start_zoom = Vector2.ZERO;

var target_position = Vector2.ZERO;

func _ready() -> void:
	Conductor.new_beat.connect(beat_hit);
	Conductor.new_step.connect(step_hit);
	
func init_cam():
	zoom = Vector2.ONE * SongData.stageZoom;
	
	load_camera_events();
	
	if !SongData.is_in_cutscene && main_scene.is_on_intro:
		target_position = main_scene.dad.global_position + Vector2(
			main_scene.dad.camera_pos[0],
			main_scene.dad.camera_pos[1]
		);
		
func convert_fnf_event(event):
	var value = event.get("v", {});
	
	var strumTime = float(event.get("strumTime", event.get("t", 0.0)));
	var duration = float(value.get("duration", 0.0));
	var easing = str(value.get("ease", "linear"));
	var ease_dir = str(value.get("easeDir", "InOut"));
	
	var duration_ms = Conductor.beats_to_ms(duration);
	
	var easing_name = CamTween.get_ease_name(easing, ease_dir);
	
	match event.get("e", ""):
		"FocusCamera":
			if typeof(value) != TYPE_DICTIONARY:
				return;
				
			var character = null;
			
			var char_id = int(value.get("char", -1));
			
			match char_id:
				0:
					character = main_scene.bf;
				1:
					character = main_scene.dad;
				2:
					character = main_scene.gf;
					
			var target = Vector2.ZERO;
			
			if is_instance_valid(character):
				target = character.global_position + Vector2(
					character.camera_pos[0],
					character.camera_pos[1]
				);
				
				target += Vector2(
					float(value.get("x", 0.0)),
					float(value.get("y", 0.0))
				);
			else:
				target = Vector2(
					float(value.get("x", global_position.x)),
					float(value.get("y", global_position.y))
				);
				
			cameraEvents.append({
				"strumTime": strumTime,
				"duration": duration_ms,
				"targetX": target.x,
				"targetY": target.y,
				"easing": easing_name
			})
			
		"ZoomCamera":
			zoomEvents.append({
				"strumTime": strumTime,
				"duration": duration_ms,
				"target": float(value.get("zoom", 1.0)),
				"easing": easing_name,
				"mode": value.get("mode", "stage")
			})
			
func load_camera_events() -> void:
	cameraEvents.clear();
	zoomEvents.clear();
	
	camera_event_index = 0;
	zoom_event_index = 0;
	
	current_event = null;
	current_zoom_event = null;
	
	var camPath = "res://assets/songs/%s/chart/camera_events.json"%[SongData.song];
	
	if !FileAccess.file_exists(camPath):
		return;
		
	var camFile = FileAccess.open(camPath, FileAccess.READ);
	if camFile == null:
		return;
		
	var parser = JSON.new();
	if parser.parse(camFile.get_as_text()) != OK:
		return;
		
	var data = parser.data;
	
	if data.has("camera events") or data.has("zoom events"):
		cameraEvents = data.get("camera events", []);
		zoomEvents = data.get("zoom events", []);
		
		useDefaultCamsEvent = data.get("ignore default cams events", true);
		useDefaultZoomEvent = data.get("ignore default zooms events", true);
		
	elif data.has("events"):
		cameraEvents.clear();
		zoomEvents.clear();
		
		useDefaultCamsEvent = false;
		useDefaultZoomEvent = false;
		
		for i in data.get("events", []):
			convert_fnf_event(i);
			
	cameraEvents.sort_custom(func(a, b): return a.get("strumTime", 0) < b.get("strumTime", 0));
	zoomEvents.sort_custom(func(a, b): return a.get("strumTime", 0) < b.get("strumTime", 0));
	
func _process(delta: float) -> void:
	process_camera_events();
	process_zoom_events();
	
	if (!SongData.is_in_cutscene && !Global.is_on_video) or useDefaultZoomEvent:
		var t = 1.0 - exp(-8.0 * delta);
		zoom = zoom.lerp(Vector2.ONE * SongData.stageZoom, t);
		
		for character in [main_scene.dad, main_scene.gf, main_scene.bf]:
			if is_instance_valid(character) && character.cam_follow_pos:
				cam_follow_poses(character);
				
		offset = offset.lerp(camOffset, 1.0 - exp(-10.0 * delta));
		
		if useDefaultCamsEvent:
			if GlobalOptions.updated_cam == "smooth":
				global_position = global_position.lerp(target_position, 1.0 - exp(-10.0 * delta));
			else:
				global_position = target_position;
				
var camera_event_index = 0;
func process_camera_events() -> void:
	if useDefaultCamsEvent:
		return;
		
	while camera_event_index < cameraEvents.size():
		var event = cameraEvents[camera_event_index];
		var strum_time = event.get("strumTime", 0);
		var duration = event.get("duration", 0);
		
		if Conductor.getSongTime < strum_time:
			break;
			
		var target = Vector2(
			event.get("targetX", global_position.x),
			event.get("targetY", global_position.y)
		);
		
		if duration <= 0:
			global_position = target;
			camera_event_index += 1;
			continue;
			
		if Conductor.getSongTime >= strum_time + duration:
			global_position = target;
			camera_event_index += 1;
			continue;
			
		if current_event != event:
			current_event = event;
			start_pos = global_position;
			
		var t = clampf(float(Conductor.getSongTime - strum_time) / float(duration), 0.0, 1.0);
		var eased = CamTween.ease_value(t, event.get("easing", "linear"));
		
		if eased == null:
			eased = t;
			
		global_position = start_pos.lerp(target, float(eased));
		
		break;
		
var zoom_event_index = 0
func process_zoom_events() -> void:
	if useDefaultZoomEvent:
		return;
		
	while zoom_event_index < zoomEvents.size():
		var event = zoomEvents[zoom_event_index]
		var strum_time = event.get("strumTime", 0);
		var duration = event.get("duration", 0);
		
		var mode = event.get("mode", "stage");
		var target_zoom = Vector2.ONE * event.get("target", 1.0);
		
		match mode:
			"stage":
				target_zoom *= SongData.stageZoom;
			_:
				pass;
				
		if Conductor.getSongTime < strum_time:
			break;
			
		if duration <= 0:
			zoom = target_zoom;
			zoom_event_index += 1;
			continue;
			
		if Conductor.getSongTime >= strum_time + duration:
			zoom = target_zoom;
			zoom_event_index += 1;
			continue;
			
		if current_zoom_event != event:
			current_zoom_event = event;
			start_zoom = zoom;
			
		var t = clampf(float(Conductor.getSongTime - strum_time) / float(duration), 0.0, 1.0);
		var eased = CamTween.ease_value(t, event.get("easing", "linear"));
		
		if eased == null:
			eased = t;
			
		zoom = start_zoom.lerp(target_zoom, float(eased));
		
		break;
		
func beat_hit(beat):
	if !GlobalOptions.screen_zoom or !useDefaultZoomEvent:
		return;
		
	if beat % 4 == 0 && !main_scene.is_on_intro:
		zoom = SongData.stageZoomBeat;
		
var cam_target = null;
func step_hit(_step):
	if !useDefaultCamsEvent:
		return;
		
	if SongData.songSections.is_empty():
		return;
		
	cam_target = main_scene.dad;
	
	if SongData.songSections[Conductor.curSection]["gfSection"]:
		cam_target = main_scene.gf;
		
	elif SongData.songSections[Conductor.curSection]["mustHitSection"]:
		cam_target = main_scene.bf;
		
	if SongData.isPlaying && cam_target != null:
		target_position = cam_target.global_position + Vector2(cam_target.camera_pos[0], cam_target.camera_pos[1]);
		
var camOffset = Vector2.ZERO;
var cam_offset_values = {
	"singLeft": Vector2.LEFT,
	"singDown": Vector2.DOWN,
	"singUp": Vector2.UP,
	"singRight": Vector2.RIGHT
};
func cam_follow_poses(new_char):
	var anim = new_char.curAnim;
	
	if (new_char.is_player && new_char.curCharacter != "tankman" && new_char.curCharacter != "pico") or (!new_char.is_player):
		anim = swap_sing_anim(anim);
		
	camOffset = cam_offset_values.get(anim, Vector2.ZERO)*25;
	
func swap_sing_anim(anim):
	return {
		"singLeft": "singRight",
		"singRight": "singLeft"
	}.get(anim, anim);
	

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
	Conductor.connect("new_beat", beat_hit);
	Conductor.connect("new_step", step_hit);
	
	var camPath = "res://assets/songs/%s/chart/camera_events.json"%[SongData.song];
	if FileAccess.file_exists(camPath):
		var camFile = FileAccess.open(camPath, FileAccess.READ);
		var camJsonData = JSON.new();
		camJsonData.parse(camFile.get_as_text());
		
		cameraEvents = camJsonData.get_data()["camera events"];
		zoomEvents = camJsonData.get_data()["zoom events"];
		
		useDefaultCamsEvent = camJsonData.get_data()["ignore default cams events"];
		useDefaultZoomEvent = camJsonData.get_data()["ignore default zooms events"];
		
		camFile.close();
		
	zoom = SongData.stageZoom;
	
	if SongData.is_not_in_cutscene && main_scene.is_on_intro:
		target_position = main_scene.dad.global_position + Vector2(main_scene.dad.camera_pos[0], main_scene.dad.camera_pos[1]);
		
func _process(delta: float) -> void:
	if (SongData.is_not_in_cutscene && !Global.is_on_video) or useDefaultZoomEvent:
		var t = 1.0 - exp(-8.0 * delta);
		zoom = lerp(zoom, SongData.stageZoom, t);
		
	for i in cameraEvents:
		if useDefaultCamsEvent:
			continue;
			
		if i["duration"] <= 0:
			if Conductor.getSongTime >= i["strumTime"]:
				global_position = Vector2(i["targetX"], i["targetY"]);
				
			continue;
			
		if Conductor.getSongTime >= i["strumTime"] && Conductor.getSongTime < i["strumTime"] + i["duration"]:
			if current_event != i:
				current_event = i;
				start_pos = global_position;
				
			var t = (Conductor.getSongTime - i["strumTime"]) / i["duration"];
			t = CamTween.ease_value(t, i["easing"]);
			
			global_position = lerp(start_pos, Vector2(i["targetX"], i["targetY"]), t);
			
	for i in zoomEvents:
		if useDefaultZoomEvent:
			continue;
			
		if i["duration"] <= 0:
			if Conductor.getSongTime >= i["strumTime"]:
				zoom = Vector2.ONE * i["target"];
				
			continue;
			
		if Conductor.getSongTime >= i["strumTime"] && Conductor.getSongTime < i["strumTime"] + i["duration"]:
			if current_zoom_event != i:
				current_zoom_event = i;
				start_zoom = zoom;
				
			var t = (Conductor.getSongTime - i["strumTime"]) / i["duration"];
			t = CamTween.ease_value(t, i["easing"]);
			
			zoom = start_zoom.lerp(Vector2.ONE * i["target"], t);
			
	for i in [main_scene.dad, main_scene.gf, main_scene.bf]:
		if i == null:
			continue;
			
		if i.cam_follow_pos:
			cam_follow_poses(i);
			
	offset = lerp(offset, camOffset, 1.0 - exp(-10.0 * delta));
	
	if useDefaultCamsEvent:
		if GlobalOptions.updated_cam == "smooth":
			global_position = global_position.lerp(target_position, 1.0 - exp(-10.0 * delta));
		else:
			global_position = target_position;
			
func beat_hit(beat):
	if !GlobalOptions.screen_zoom or !useDefaultZoomEvent:
		return;
		
	if beat % 4 == 0 && !main_scene.is_on_intro:
		zoom = SongData.stageZoomBeat;
		
var cam_target = null;
func step_hit(_step):
	if !useDefaultCamsEvent:
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
	camOffset = cam_offset_values.get(new_char.curAnim, Vector2.ZERO)*25;
	

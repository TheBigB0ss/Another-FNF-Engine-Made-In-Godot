extends Control

var timeline_width = 0.0;

const TRACK_AMOUNT = 2;

var camera_position = Vector2.ZERO;
var camera_zoom = 1.0;

@onready var camEvents = $cam_events;
@onready var zoomEvents = $zoom_events;

func _process(_delta: float) -> void:
	queue_redraw();
	
func _draw():
	for i in TRACK_AMOUNT:
		var y = i * 40;
		draw_rect(Rect2(size.x / 2 - time_to_position(Conductor.getSongTime), y, timeline_width, 40), Color(0.18, 0.18, 0.18));
		draw_line(Vector2(size.x / 2 - time_to_position(Conductor.getSongTime), y), Vector2(size.x / 2 - time_to_position(Conductor.getSongTime) + timeline_width, y), Color(0.35,0.35,0.35));
		
	var beat_pixels = (60.0 / Conductor.bpm) * 100;
	var x = 0.0;
	while x <= timeline_width:
		draw_line(
			Vector2((size.x / 2 - time_to_position(Conductor.getSongTime))+x, 0),
			Vector2((size.x / 2 - time_to_position(Conductor.getSongTime))+x, 40*TRACK_AMOUNT),
			Color.WHITE
		);
		x += beat_pixels;
		
	draw_line(
		Vector2(size.x/2, 0),
		Vector2(size.x/2, 40*TRACK_AMOUNT),
		Color.RED,
		2.0
	);
	
func get_track():
	return int((get_global_mouse_position().y - global_position.y) / 40);
	
func get_timeline_offset():
	return size.x / 2.0 - (Conductor.getSongTime / 1000.0) * 100;
	
func position_to_time(val):
	return ((val - get_timeline_offset()) / 100.0) * 1000.0
	
func time_to_position(val):
	return (val / 1000.0) * 100;
	
func get_track_y(track):
	return position.y + track * 40 + 40 * 0.5;
	
func mouse_inside():
	return get_global_mouse_position().x >= get_timeline_offset() && get_global_mouse_position().x <= get_timeline_offset() + timeline_width;

@tool
extends Node2D

@export var radius = 40.0:
	set(value):
		radius = abs(value);
		queue_redraw();
		
@export var useArc = false:
	set(val):
		useArc = val;
		queue_redraw();
		
@export var circle_color = Color.ALICE_BLUE:
	set(val):
		circle_color = val;
		queue_redraw();
		
@export var progress_color = Color.AQUA:
	set(val):
		progress_color = val;
		queue_redraw();
		
@export var progress = 0.0:
	set(value):
		progress = clamp(value, 0.0, 1.0);
		queue_redraw();
		
func _draw() -> void:
	var point_count = 128;
	if useArc:
		draw_arc(Vector2.ZERO, radius, 0.0, PI*2, point_count, circle_color, 8.0, true);
		
		if progress > 0.0:
			draw_arc(Vector2.ZERO, radius, -PI / 2.0, (-PI / 2.0) + PI*2 * progress, point_count, Color.AQUA, 8.0, true);
			
	else:
		draw_circle(Vector2.ZERO, radius, circle_color, true, -1.0, true);
		
		if progress > 0.0:
			var points = [];
			points.append(Vector2.ZERO);
			
			for i in range(point_count + 1):
				var angle = lerpf(-PI / 2.0, (-PI / 2.0) + PI*2 * progress, float(i) / point_count);
				points.append(Vector2(cos(angle) * radius, sin(angle) * radius));
				
			draw_colored_polygon(points, Color.AQUA);
			

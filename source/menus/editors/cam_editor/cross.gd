extends Node2D

func _draw():
	draw_line(Vector2(-10,0), Vector2(10,0), Color.WHITE, 2)
	draw_line(Vector2(0,-10), Vector2(0,10), Color.WHITE, 2)
	draw_circle(Vector2.ZERO, 3, Color.WHITE)
	
func _process(_delta):
	queue_redraw();

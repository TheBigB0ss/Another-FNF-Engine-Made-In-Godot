extends Node2D

var GRID_SIZE = 40;
var grid_Y_size = 40;

var keyAmount = 5;
var tileSize = 32;

var tiles = 0;

func _ready():
	queue_redraw();
	
func _redraw_grid(new_tile):
	GRID_SIZE = 40;
	tiles = new_tile;
	queue_redraw();
	
func _draw():
	for i in grid_Y_size:
		for j in tiles:
			draw_rect(Rect2(j * 40, i * 40, 40, 40), Color.GRAY);
			if (i + j) % 2 == 0:
				draw_rect(Rect2(j * 40, i * 40, 40, 40), Color.LIGHT_GRAY);
				
	draw_line(Vector2(tileSize*keyAmount*2 / 2, 0), Vector2(tileSize*keyAmount*2 / 2, tileSize*40), Color.BLACK, 3);
	draw_line(Vector2(tileSize*keyAmount*4 / 2, 0), Vector2(tileSize*keyAmount*4 / 2, tileSize*40), Color.BLACK, 3);
	
	if tiles > 10:
		draw_line(Vector2(tileSize*keyAmount*6 / 2, 0), Vector2(tileSize*keyAmount*6 / 2, tileSize*40), Color.BLACK, 3);

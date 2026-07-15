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
			draw_rect(Rect2(j * 40, i * 40, 40, 40), Color(0.12, 0.12, 0.12, 1));
			if (i + j) % 2 == 0:
				draw_rect(Rect2(j * 40, i * 40, 40, 40), Color(0.20, 0.20, 0.20, 1));
				
	draw_line(Vector2(tileSize*keyAmount*2 / 2, 0), Vector2(tileSize*keyAmount*2 / 2, tileSize*40), Color.BLACK, 3);
	draw_line(Vector2(tileSize*keyAmount*4 / 2, 0), Vector2(tileSize*keyAmount*4 / 2, tileSize*40), Color.BLACK, 3);
	
	if tiles > 10:
		draw_line(Vector2(tileSize*keyAmount*6 / 2, 0), Vector2(tileSize*keyAmount*6 / 2, tileSize*40), Color.BLACK, 3);
		
	for y in range(grid_Y_size / 4):
		var pos_y = y * GRID_SIZE * 4;
		draw_line(Vector2(0, pos_y), Vector2(GRID_SIZE * tiles, pos_y), Color.INDIAN_RED, 3);
		
	for y in range(grid_Y_size / 16):
		var pos_y = y * GRID_SIZE * 16;
		draw_line(Vector2(0, pos_y), Vector2(GRID_SIZE * tiles, pos_y), Color.DARK_TURQUOISE, 3);
		
func mouse_inside_grid():
	var mouse = get_local_mouse_position();
	return mouse.x >= 0 && mouse.y >= 0 && mouse.x < GRID_SIZE * tiles && mouse.y < GRID_SIZE * grid_Y_size;

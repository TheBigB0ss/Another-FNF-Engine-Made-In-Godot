extends Node2D

var GRID_SIZE = 40;
var grid_Y_size = 40;

var keyAmount = 5;
var tileSize = 32;

var tiles = 0;

@export var node = Node2D
@export var camera = Camera2D;

func _ready():
	queue_redraw();
	
func _process(_delta):
	queue_redraw();
	
func _redraw_grid(new_tile):
	GRID_SIZE = 40;
	tiles = new_tile;
	queue_redraw();
	
func _draw():
	if camera == null:
		return
		
	var viewport_size = get_viewport_rect().size;
	
	var start_y = floor((camera.global_position.y - viewport_size.y / 2 - (GRID_SIZE * 4)) / GRID_SIZE) * GRID_SIZE;
	if node.curSection == 0:
		start_y = max(0, start_y);
		
	var end_y = ceil((camera.global_position.y + viewport_size.y / 2 + (GRID_SIZE * 4)) / GRID_SIZE) * GRID_SIZE;
	
	for i in range(int(start_y / GRID_SIZE), int(end_y / GRID_SIZE) + 1):
		var y = i * GRID_SIZE;
		for j in range(tiles):
			var color = Color(0.12,0.12,0.12);
			if (i + j) % 2 == 0:
				color = Color(0.20,0.20,0.20);
				
			draw_rect(Rect2(j * GRID_SIZE, y, GRID_SIZE, GRID_SIZE), color);
			
			if i % 4 == 0:
				draw_line(Vector2(0, y), Vector2(GRID_SIZE * tiles, y), Color.INDIAN_RED, 3);
				
			if i % 16 == 0:
				draw_line(Vector2(0, y), Vector2(GRID_SIZE * tiles, y), Color.DARK_TURQUOISE, 3);
				
	draw_line(Vector2(tileSize * keyAmount * 2 / 2, start_y), Vector2(tileSize * keyAmount * 2 / 2, end_y), Color.BLACK, 3);
	
	if tiles > 8:
		draw_line(Vector2(tileSize * keyAmount * 4 / 2, start_y), Vector2(tileSize * keyAmount * 4 / 2, end_y), Color.BLACK, 3);
		
func mouse_inside_grid():
	var mouse = get_local_mouse_position();
	var viewport_size = get_viewport_rect().size;
	
	var start_y = floor((camera.global_position.y - viewport_size.y / 2 - (GRID_SIZE * 4)) / GRID_SIZE) * GRID_SIZE;
	if node.curSection == 0:
		start_y = max(0, start_y);
		
	var end_y = ceil((camera.global_position.y + viewport_size.y / 2 + (GRID_SIZE * 4)) / GRID_SIZE) * GRID_SIZE;
	
	return mouse.x >= 0 && mouse.y >= start_y && mouse.x < GRID_SIZE * tiles && mouse.y < end_y;
	
func get_side():
	var column = int(get_local_mouse_position().x / GRID_SIZE);
	return int(column / 4);

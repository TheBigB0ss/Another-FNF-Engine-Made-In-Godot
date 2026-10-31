class_name SustainLine extends Node2D

var lineTex:Texture2D;
var noteEndTex:Texture2D;

var additional_scale = Vector2.ONE;

var sustainLine:Line2D;

var width = 50.0;

var note_end_height:
	get:
		if noteEndTex == null:
			return 0.0;
			
		var speed_scale = absf(Conductor.songSpeed / 1.5);
		var pixel_scale = 7.0 if SongData.isPixelStage else 1.0;
		
		return noteEndTex.get_height() * pixel_scale / speed_scale;
		
var length = 0.0:
	set(value):
		length = value;
		update_line();
		queue_redraw();
		
func _ready() -> void:
	sustainLine = Line2D.new();
	sustainLine.texture_mode = Line2D.LINE_TEXTURE_TILE;
	sustainLine.width = width;
	sustainLine.position = Vector2.ZERO;
	add_child(sustainLine);
	
	update_line();
	
func update_line():
	if !is_instance_valid(sustainLine):
		return;
		
	sustainLine.width = width;
	sustainLine.texture = get_texture(lineTex);
	sustainLine.clear_points();
	
	var line_length = maxf(0.0, length - note_end_height);
	
	sustainLine.add_point(Vector2.ZERO);
	sustainLine.add_point(Vector2(0.0, line_length));
	
var textures_cache = {};
func get_texture(tex:Texture2D, rotated = true):
	if !is_instance_valid(tex):
		return;
		
	if textures_cache.has(tex.resource_path):
		return textures_cache[tex.resource_path];
		
	var img = tex.get_image();
	if rotated:
		img.rotate_90(CLOCKWISE);
		
	var texture = ImageTexture.create_from_image(img);
	textures_cache[tex.resource_path] = texture;
	
	return texture;
	
func _draw() -> void:
	var speed_scale = absf(Conductor.songSpeed / 1.5);
	
	#if length > 0.0 && lineTex != null:
	#	draw_texture_rect(lineTex ,Rect2(-width / 2.0, 0.0, width, length), true)
		
	if noteEndTex == null && length <= 0.0:
		return
		
	var pixel_scale = 7.0 if SongData.isPixelStage else 1.0;
	
	var height = minf(
		length, 
		noteEndTex.get_size().y * pixel_scale / speed_scale
	)
	var noteEndHeight = height * speed_scale / pixel_scale
	
	var note_y = length - height;
	draw_texture_rect_region(
		noteEndTex,
		Rect2(
			-width / 2.0, 
			note_y, 
			width, 
			height
		),
		Rect2(
			0.0, 
			noteEndTex.get_size().y - noteEndHeight, 
			noteEndTex.get_size().x, 
			noteEndHeight
		)
	)
	
func _process(_delta: float) -> void:
	queue_redraw();
	

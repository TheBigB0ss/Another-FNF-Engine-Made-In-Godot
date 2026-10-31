extends Sprite2D

var ratingPart = "";
var folderPart = "";
var numScore = [];

var shit_spr = Sprite2D.new();

var combo = "";

func _ready() -> void:
	combo = str(int(randf_range(100, 999)));
	
	ratingPart = "";
	folderPart = "default";
	
	for i in 10:
		numScore.append(load("res://assets/images/hud/rating/%s/nums/num%s%s.png"%[folderPart, i, ratingPart]));
		
func _draw() -> void:
	for i in len(combo):
		shit_spr.texture = numScore[int(combo[i])];
		draw_texture(numScore[int(combo[i])], Vector2(i*90, 0));
		
func get_num_at_mouse():
	var mouse = get_global_mouse_position();
	
	for i in len(combo):
		var tex = numScore[int(combo[i])];
		
		if tex == null:
			continue;
			
		var pos = to_global(Vector2(i * 90, 0));
		var size = tex.get_size() * scale;
		var rect = Rect2(pos - size / 2.0, size);
		
		if rect.has_point(mouse):
			return i;
			
	return -1;

extends Sprite2D

var ratingPart = "";
var folderPart = "";
var numScore = [];

var shit_spr = Sprite2D.new();

func _ready() -> void:
	ratingPart = "";
	folderPart = "default";
	
	for i in 10:
		numScore.append(load("res://assets/images/hud/rating/%s/nums/num%s%s.png"%[folderPart, i, ratingPart]));
		
func _draw() -> void:
	var combo = str(int(randf_range(100, 999)));
	for i in len(combo):
		shit_spr.texture = numScore[int(combo[i])];
		draw_texture(numScore[int(combo[i])], Vector2(i*90, 0));

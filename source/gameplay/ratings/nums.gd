extends Sprite2D

var ratingPart = "";
var folderPart = "";
var numScore = [];

var grav = 0.25;
var fade_speed = 12.0;
var max_fall_speed = 2;

var coolNumsPos = Vector2.ZERO;
var velocity = Vector2.ZERO;
var acceleration = Vector2.ZERO;

func _ready() -> void:
	if SongData.isPixelStage:
		self.scale = Vector2(4.3,4.3);
		ratingPart = "-pixel";
		folderPart = "pixel";
	else:
		ratingPart = "";
		folderPart = "default";
		
	for i in 10:
		numScore.append(load("res://assets/images/hud/rating/%s/nums/num%s%s.png"%[folderPart, i, ratingPart]));
		
	coolNumsPos = Vector2(GlobalOptions.ratings_positions["nums"][0], GlobalOptions.ratings_positions["nums"][1]);
	
	hide();
	
func _process(delta):
	modulate.a = lerp(modulate.a, 0.0, fade_speed * delta);
	for i in nums:
		i["velocity"] += i["acceleration"] * delta;
		i["position"] += i["velocity"] * delta;
		
	queue_redraw()
	
var nums = [];
func pop_up_rating():
	position = coolNumsPos;
	nums = [];
	var coolCombo = get_tree().current_scene.get("combo");
	var combo = str(coolCombo) if GlobalOptions.updated_hud != "classic hud" else str(coolCombo).pad_zeros(3);
	for i in range(len(combo)):
		var rand_x = randf_range(-7, 12) if !SongData.isPixelStage else 0.0;
		var rand_y = randf_range(-5, 20) if !SongData.isPixelStage else 0.0;
		
		var numbers = {
			"texture": numScore[int(combo[i])],
			"position": Vector2(i * 90 + rand_x, rand_y) if !SongData.isPixelStage else Vector2(i * 10 + rand_x, rand_y),
			"velocity": Vector2(-randi_range(0, 50), -randi_range(130, 190)) if !SongData.isPixelStage else Vector2(-randi_range(0, 10),-randi_range(140, 175)),
			"acceleration": Vector2(0, randf_range(420, 760)) if !SongData.isPixelStage else Vector2(0, 550)
		};
		
		nums.append(numbers);
		
	modulate.a = 20.0;
	queue_redraw();
	show();
	
func _draw() -> void:
	for i in nums:
		draw_texture(i["texture"], i["position"]);
		

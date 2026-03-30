extends Sprite2D

var ratingPart = "";
var folderPart = "";

var grav = 0.25;
var fade_speed = 12.0;
var max_fall_speed = 2;

var coolComboPos = Vector2.ZERO;
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

func _ready() -> void:
	if SongData.isPixelStage:
		self.scale = Vector2(3.5,3.5);
		ratingPart = "-pixel";
		folderPart = "pixel";
	else:
		ratingPart = "";
		folderPart = "default";
		
	texture = load("res://assets/images/hud/rating/%s/combo%s.png"%[folderPart, ratingPart]);
	
	coolComboPos = Vector2(GlobalOptions.ratings_positions["combo"][0], GlobalOptions.ratings_positions["combo"][1]);
	hide();
	
func _process(delta):
	modulate.a = lerp(modulate.a, 0.0, fade_speed * delta);
	velocity += acceleration * delta;
	position += velocity * delta;
	
func pop_up_rating():
	acceleration = Vector2(0, 550);
	velocity = Vector2(-randi_range(0, 10),-randi_range(140, 175));
	
	position = coolComboPos;
	
	texture = load("res://assets/images/hud/rating/%s/combo%s.png"%[folderPart, ratingPart]);
	modulate.a = 20.0;
	queue_redraw();
	show();

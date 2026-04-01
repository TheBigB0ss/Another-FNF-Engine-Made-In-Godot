extends Sprite2D

var ratings = ["sick", "good", "bad", "shit", "miss"];
var ratingPart = "";
var folderPart = "";

var grav = 0.25;
var fade_speed = 12.0;
var max_fall_speed = 2;

var coolRatingPos = Vector2.ZERO;
var velocity = Vector2.ZERO;
var acceleration = Vector2.ZERO;

func _ready() -> void:
	if SongData.isPixelStage:
		self.scale = Vector2(3.5,3.5);
		ratingPart = "-pixel";
		folderPart = "pixel";
	else:
		ratingPart = "";
		folderPart = "default";
		
	coolRatingPos = Vector2(GlobalOptions.ratings_positions["rating"][0], GlobalOptions.ratings_positions["rating"][1]);
	hide();
	
func _process(delta):
	modulate.a = lerp(modulate.a, 0.0, fade_speed * delta);
	velocity += acceleration * delta;
	position += velocity * delta;
	
func pop_up_rating(rating):
	acceleration = Vector2(0, 550);
	velocity = Vector2(-randi_range(0, 10),-randi_range(140, 175));
	
	global_position = coolRatingPos;
	
	texture = load("res://assets/images/hud/rating/%s/%s.png"%[folderPart, ratings[rating] + ratingPart]);
	modulate.a = 20.0;
	show();
	

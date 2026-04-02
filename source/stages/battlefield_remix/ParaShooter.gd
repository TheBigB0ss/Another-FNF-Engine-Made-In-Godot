class_name ParaShooter extends AnimatedSprite2D

var angle_rotate = 0.0;
var angleTime = 0.0;

enum Paratrooters{
	Freddy = 0,
	Box = 1,
	Soldier1 = 2,
	Soldier2 = 3
};
var parashooterId = null;
var paratrootersuffix = "";

func _ready() -> void:
	parashooterId = null;
	paratrootersuffix = "";
	if int(randf_range(0, 100)) > 10:
		parashooterId = Paratrooters.Soldier1 if int(randf_range(0, 50)) <= 25 else Paratrooters.Soldier2;
	else:
		parashooterId = Paratrooters.Box if int(randf_range(0, 50)) <= 35 else Paratrooters.Freddy;
		
	match parashooterId:
		Paratrooters.Soldier1:
			paratrootersuffix = "Tankmen1";
		Paratrooters.Soldier2:
			paratrootersuffix = "Tankmen2";
		Paratrooters.Box:
			paratrootersuffix = "Box";
		Paratrooters.Freddy:
			paratrootersuffix = "Freddy";
			
	if paratrootersuffix != "" && parashooterId != null:
		angle_rotate = randf_range(13, 27);
		sprite_frames = load("res://assets/stages/week7/remix/paratroopers.res");
		position.x = randf_range(45, 675);
		play("BG_Falling%s"%[paratrootersuffix]);
		flip_h = randf_range(0,100) <= 50 && paratrootersuffix != "Freddy";
		
func _process(delta: float) -> void:
	var fallSpeed = 120.0;
	var rotatingSpeed = randf_range(2.9, 6.2);
	
	position.y += fallSpeed * delta;
	
	angleTime += rotatingSpeed * delta;
	rotation = sin(angleTime / 1.5) * deg_to_rad(angle_rotate);
	
	if position.y >= 1310:
		queue_free();

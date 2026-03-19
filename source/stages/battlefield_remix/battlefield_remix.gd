extends Stage

enum Paratrooters{
	Freddy = 0,
	Box = 1,
	Soldier1 = 2,
	Soldier2 = 3
};
var parashooterId = null;
var paratrootersuffix = "";

@onready var soldiersGrp = $soldiers;
@onready var paratrooters = $paratroopers;

@onready var rolling_tank1 = $tank1;
@onready var rolling_tank2 = $tank2;

var steve_chart = [];
var steve_data = {};
var steve_time = false;

var tank_angle = 0.0;
var angleTime = 0.0;

func _ready():
	if SongData.isPlaying:
		if game.curSong == "stress-remix":
			game.newOpponentStrum.hide();
			
func _process(delta):
	tank_angle += delta*0.1;
	
	rolling_tank1.position = Vector2(770 + cos(tank_angle) * 2250, 1680 + sin(tank_angle) * 1150);
	rolling_tank1.rotation = tank_angle + PI/2;
	
	rolling_tank2.position = Vector2(770 + cos(tank_angle) * 2250, 1680 + sin(tank_angle) * 1150);
	rolling_tank2.position.x -= 420;
	rolling_tank2.rotation = tank_angle + PI/2;
	
	for i in paratrooters.get_children():
		i.position.y += 4.0/2.0;
		
		angleTime += delta;
		i.rotation = sin(angleTime/1.5) * deg_to_rad(24);
		
		if i.position.y >= 1310:
			paratrooters.remove_child(i);
			i.queue_free();
			
	if SongData.isPlaying:
		if game.curSong == "stress-remix":
			if steve_time:
				game.new_opponent.position.x = min(game.new_opponent.position.x + 1330*delta, 550);
				
			if game.new_opponent.position.x < 550:
				game.newOpponentStrum.modulate.a = 0.0;
				if game.iconP3 != null:
					game.iconP3.modulate.a = 0.0;
			else:
				game.newOpponentStrum.modulate.a = lerp(game.newOpponentStrum.modulate.a, 1.0, 0.16);
				game.iconP3.modulate.a = lerp(game.iconP3.modulate.a, 1.0, 0.16);
				steve_time = false;
				
func beat_hit(beat):
	if beat % 2 == 0:
		crowd_dance();
		
	if beat % 6 == 0 && !GlobalOptions.low_quality:
		if int(randf_range(0, 50)) <= 20:
			create_parashooter();
			
	if game.curSong == "stress-remix":
		match beat:
			308:
				game.new_opponent._playAnim("running");
				steve_time = true;
				
func crowd_dance():
	var count = 0;
	
	while (count < soldiersGrp.get_child_count()):
		count += 1;
		soldiersGrp.get_child(count-1).play("FG_Tankmen%s"%[count]);
		
func create_parashooter():
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
		var newParatrooter = AnimatedSprite2D.new();
		newParatrooter.sprite_frames = load("res://assets/stages/week7/remix/paratroopers.res");
		newParatrooter.position.x = randf_range(45, 675);
		newParatrooter.play("BG_Falling%s"%[paratrootersuffix]);
		newParatrooter.flip_h = randf_range(0,100) <= 50 && paratrootersuffix != "Freddy";
		paratrooters.add_child(newParatrooter);
		

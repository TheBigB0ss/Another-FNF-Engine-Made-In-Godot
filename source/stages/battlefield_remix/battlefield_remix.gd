extends Stage

@onready var soldiersGrp = $soldiers;
@onready var paratrooters = $paratroopers;

@onready var rolling_tank1 = $tank1;
@onready var rolling_tank2 = $tank2;

var steve_chart = [];
var steve_data = {};
var steve_time = false;

var tank_angle = 0.0;

@onready var steve = $steve;
@onready var steveStrum = $steveStrum;

func _process(delta):
	tank_angle += delta*0.1;
	
	rolling_tank1.position = Vector2(770 + cos(tank_angle) * 2250, 1680 + sin(tank_angle) * 1150);
	rolling_tank1.rotation = tank_angle + PI/2;
	
	rolling_tank2.position = Vector2(770 + cos(tank_angle) * 2250, 1680 + sin(tank_angle) * 1150);
	rolling_tank2.position.x -= 420;
	rolling_tank2.rotation = tank_angle + PI/2;
	
	if SongData.isPlaying:
		if game.curSong == "stress-remix":
			if steve_time:
				steve.position.x = min(steve.position.x + 1330*delta, 80);
				
			if steve.position.x > 79:
				steveStrum.enable = true;
				steveStrum.modulate.a = lerp(steveStrum.modulate.a, 0.70, 0.15);
				steve_time = false;
				
func beat_hit(beat):
	if beat % 2 == 0:
		crowd_dance();
		
	if beat % 6 == 0 && !GlobalOptions.low_quality:
		if int(randf_range(0, 50)) <= 23:
			var newParashooter = ParaShooter.new();
			paratrooters.add_child(newParashooter);
			
	if game.curSong == "stress-remix":
		match beat:
			308:
				steve._playAnim("running");
				steve_time = true;
				
func crowd_dance():
	var count = 0;
	
	while (count < soldiersGrp.get_child_count()):
		count += 1;
		soldiersGrp.get_child(count-1).play("FG_Tankmen%s"%[count]);
		

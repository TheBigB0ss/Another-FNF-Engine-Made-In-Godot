extends Node2D

@onready var coolCar = $'car';
var car_pass_timer = 0;
var car_can_pass = false;

func _ready():
	Global.connect("new_beat", beat_hit);
	
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
	if GlobalOptions.low_quality:
		$Control.hide();
		$LimoBg.hide();
		
	if SongData.player3 != "" && SongData.haveTwoOpponents:
		var newOpponent = get_tree().current_scene.get("new_opponent");
		if newOpponent != null:
			newOpponent.z_index = 2;
			
func soakedAppears():
	return randi_range(0, 1000);
	
func trigger_car():
	if Global.is_playing:
		SoundStuff.playAudio("carPass", false);
		car_can_pass = true;
		
func _process(delta):
	if car_can_pass:
		car_pass_timer += delta;
		if car_pass_timer >= 1:
			fastCarZOOOOOOOOOOOOOOOOOOMMMMMMMMMMM();
			car_pass_timer = 0;
			car_can_pass = false;
			
func fastCarZOOOOOOOOOOOOOOOOOOMMMMMMMMMMM():
	var tw = get_tree().create_tween();
	tw.tween_property(coolCar, "position:x", -4000, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	if coolCar.position.x <= -4000:
		restFastCar();
		
func restFastCar():
	coolCar.position.x = 3180
	
func beat_hit(beat):
	if beat % 6 == 0 && randf_range(0, 40) <= 10 && !get_tree().current_scene.get("is_on_intro"):
		trigger_car();

extends Stage

@onready var coolCar = $'car';
var car_pass_timer = 0;
var car_can_pass = false;

func _ready():
	if GlobalOptions.low_quality:
		$Control.hide();
		$LimoBg.hide();
		
func trigger_car():
	if SongData.isPlaying:
		Sound.playAudio("carPass", false);
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
	trigger_dancers();
	if beat % 6 == 0 && randf_range(0, 40) <= 10 && !get_tree().current_scene.get("is_on_intro"):
		trigger_car();
		
func trigger_dancers():
	var i = 0;
	while i < 4:
		$dancers.get_child(i-1).play("bg dancer sketch PINK");
		i += 1;

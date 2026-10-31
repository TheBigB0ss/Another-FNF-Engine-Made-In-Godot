extends Stage

var train_canMove = false;
var train_time = 0;
var randomLight = '';

@onready var lightsBg = $'lightBg';

var train: Node2D;

const TRAIN_START = Vector2(4140.0, 610.0);
const TRAIN_END = -8200.0;

const TRAIN_WAIT_TIME = 5.0;
const TRAIN_MOVE_TIME = 0.6;

var lights = [];

var train_moving = false;

#if you are reading this, just for let you know, i will not improve this code. I hate week 3 and i refuse to recode this shit

func setRandomLight() -> void:
	if lights.is_empty():
		return
		
	randomLight = lights.pick_random();
	lightsBg.texture = randomLight;
	lightsBg.modulate.a = 1.0;
	
	var tw = create_tween();
	tw.tween_property(lightsBg, "modulate:a", 0.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
func _ready():
	for i in range(5):
		lights.append(load("res://assets/stages/week3/win%d.png"%[i]));
		
	create_train();
	
func create_train():
	train = Node2D.new();
	train.name = "Train";
	add_child(train);
	move_child(train, 4);
	
	for i in range(8):
		var wagon = Sprite2D.new();
		wagon.name = "TrainWagon%s"%[i];
		wagon.texture = preload("res://assets/stages/week3/train.png");
		wagon.position.x = i * 400.0;
		train.add_child(wagon);
		
	train.position = TRAIN_START;
	
func _process(delta: float) -> void:
	if train_canMove:
		train_time += delta;
		if train_time >= TRAIN_WAIT_TIME:
			train_time = 0.0;
			train_canMove = false;
			Sound.playAudio("train_passes");
			train_moving = true;
			
	if train_moving:
		train_time += delta;
		if train_time >= 4.7:
			train.position.x -= 400.0 * delta * 60.0;
			if train.position.x <= TRAIN_END:
				reset_train();
				
func trigger_train():
	Sound.playAudio("train_passes");
	train_canMove = true;
	
var train_tween = null;
func update_train() -> void:
	train_moving = true;
	
	if is_instance_valid(game.gf):
		if game.gf.animList.has("special idle dance"):
			game.gf._playAnim("special idle dance");
			
func reset_train():
	train_time = 0.0;
	train_canMove = false;
	train_moving = false;
	train.position = TRAIN_START;
	
func beat_hit(beat) -> void:
	if beat % 4 == 0:
		setRandomLight();
		
	#if (beat % 8 == 4 && randi_range(0, 59) <= 50 && !game.is_on_intro):
	#	trigger_train();
		

extends Node2D

var lights = [0, 1, 2, 3, 4];
var train_canMove = false;
var train_time = 0;
var randomLight = '';

@onready var lightsBg = $'lightBg';
@onready var trainBg = $'train';

#if you are reading this, just for let you know, i will not improve this code. I hate week 3 and i refuse to recode this shit

func setRandomLight():
	randomLight = lights.pick_random();
	lightsBg.texture = load("res://assets/stages/week3/win%s.png"%[randomLight]);
	lightsBg.modulate.a = 1;
	
	var tw = get_tree().create_tween();
	tw.tween_property(lightsBg, "modulate:a", 0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
func _ready():
	Conductor.connect("new_beat", beat_hit);
	
func _process(delta):
	if train_canMove:
		train_time += delta;
		if train_time >= 5.0:
			train_time = 0;
			train_canMove = false;
			update_train();
			
func trigger_train():
	Sound.playAudio("train_passes", false);
	train_canMove = true;
	
func update_train():
	var tw = get_tree().create_tween();
	tw.tween_property(trainBg, "position:x", -8200, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	var gf_anim = get_tree().current_scene.get("gf");
	
	if gf_anim.animList.has("special idle dance") && SongData.gfPlayer != "none" && gf_anim != null:
		gf_anim._playAnim("special idle dance");
		
	if trainBg.position.x <= -8200:
		reset_train();
		
func reset_train():
	train_time = 0;
	train_canMove = false;
	trainBg.position = Vector2(4140, 610);
	
func beat_hit(beat):
	if beat % 4 == 0:
		setRandomLight();
		
	if beat % 8 == 4 && int(randf_range(0, 60)) <= 10 && !get_tree().current_scene.get("is_on_intro"):
		trigger_train();

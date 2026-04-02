extends Node2D

var tankman_time = 0.0;
var direction_right = false;
var end_offset = 50;

@onready var runner_anim = $Character_Animation;
@onready var runner_spr = $Character_Sprite;

var death_animID = 0;

var is_dead = false;

func _ready():
	self.show();
	runner_spr.flip_h = direction_right;
	runner_anim.play("tankman running");
	death_animID = choice_shoot_anim();
	
var cool_down = 0;
func _process(delta):
	if !is_dead:
		if direction_right:
			cool_down = 220;
			position.x = (-735*0.80) + (Conductor.getSongTime - tankman_time)*1.2;
		else:
			cool_down = 210;
			position.x = (2290*0.65) - (Conductor.getSongTime - tankman_time)*1.2;
			
	if Conductor.getSongTime >= tankman_time+cool_down && !is_dead:
		runner_anim.play("John Shot %s"%[death_animID]);
		runner_spr.offset.x = 140
		
		is_dead = true;
		
func choice_shoot_anim():
	return int(randi_range(1, 2));
	
func _on_character_animation_animation_finished(anim_name):
	if anim_name.begins_with('Jonh Shot'):
		self.queue_free();

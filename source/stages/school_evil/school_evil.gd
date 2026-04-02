extends Node2D

var fade_timer = 0;
var white_fade_timer = 0;
var is_in_cutscene = false;

@onready var senpai_timer = $"senpai cutscene/senpai fade timer";
@onready var senpai = $"senpai cutscene/senpaiCrazy";

func _ready():
	if GlobalOptions.use_shader:
		$CanvasLayer.show();
	else:
		$CanvasLayer.hide();
		
func _process(delta: float) -> void:
	if is_in_cutscene:
		if fade_timer == 5:
			Sound.playAudio("Senpai_Dies", false);
			senpai.animation.play("Senpai Pre Explosion instance 1/ ");
			
		white_fade_timer += 1*delta;
		
		if white_fade_timer >= 8.1:
			var tween = get_tree().create_tween();
			tween.tween_property($'senpai cutscene/white_bg', "modulate:a", 1, 0.5)
			
		if white_fade_timer >= 11.5 && white_fade_timer <= 11.6:
			end_cutscene();
			
func start_cutscene():
	$"senpai cutscene".show();
	Global.is_on_video = true;
	is_in_cutscene = true;
	senpai_timer.start(0.6);
	MusicManager.process_mode = 2;
	MusicManager._play_music("LunchboxScary", false, true);
	
func end_cutscene():
	Global.is_on_video = false;
	is_in_cutscene = false;
	Global.emit_signal("end_senpai_cutscene");
	$"senpai cutscene".hide();
	
func _on_senpai_fade_timer_timeout() -> void:
	fade_timer += 1;
	if fade_timer <= 5:
		senpai_timer.start(0.6);
		
	match fade_timer:
		1:
			senpai.modulate.a = 0.4;
		2:
			senpai.modulate.a = 0.6;
		3:
			senpai.modulate.a = 0.8;
		4:
			senpai.modulate.a = 1;

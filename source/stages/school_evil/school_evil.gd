extends Node2D

var fade_timer = 0;
var white_fade_timer = 0;

var is_in_cutscene = false;

@onready var senpai_timer = $"senpai cutscene/senpai fade timer";
@onready var senpai = $"senpai cutscene/senpaiCrazy";
@onready var senpai_cutscene = $"senpai cutscene";

@onready var white_fade = $'senpai cutscene/white_bg';

signal end_senpai_cutscene;

func _ready():
	$CanvasLayer.visible = GlobalOptions.use_shader;
	
func _process(delta: float) -> void:
	if !is_in_cutscene:
		return;
		
	white_fade_timer += 1*delta;
	
	if white_fade_timer >= 8.1:
		white_fade.modulate.a = lerp(white_fade.modulate.a, 1.0, 1.0 - exp(-8.0 * delta));
		
	if white_fade_timer >= 11.5:
		end_cutscene();
		
func start_cutscene():
	senpai_cutscene.show();
	
	Global.is_on_video = true;
	SongData.is_in_cutscene = false;
	is_in_cutscene = true;
	
	fade_timer = 0;
	
	white_fade.modulate.a = 0.0;
	senpai.modulate.a = 0.0;
	
	senpai_timer.start(0.6);
	
	MusicManager._play_song("LunchboxScary", "music", true);
	
func end_cutscene():
	if !is_in_cutscene:
		return;
		
	Global.is_on_video = false;
	SongData.is_in_cutscene = true;
	is_in_cutscene = false;
	
	senpai_cutscene.hide();
	
	self.end_senpai_cutscene.emit();
	
func _on_senpai_fade_timer_timeout() -> void:
	fade_timer += 1;
	
	if fade_timer <= 5:
		senpai_timer.start(0.6);
		
	if fade_timer <= 4:
		senpai.modulate.a = fade_timer * 0.2;
		
	if fade_timer == 6:
		Sound.playAudio("Senpai_Dies", false);
		senpai.animation.play("Senpai Pre Explosion instance 1/ ");
		

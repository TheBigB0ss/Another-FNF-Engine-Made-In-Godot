extends Node2D

@onready var progress_bar = $reset_bar;
@onready var text = $reset_text;
@onready var bg = $"../Bg";

func _ready() -> void:
	progress_bar.modulate.a = 0.0;
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("r_reset"):
		progress_bar.progress += 0.25*delta;
	else:
		progress_bar.progress -= 0.8*delta;
		
	progress_bar.modulate.a = progress_bar.progress;
	
	text.shakingX = progress_bar.progress*20;
	text.shakingY = progress_bar.progress*20;
	
	bg.offset = Vector2(
		randf_range(-progress_bar.progress*15, progress_bar.progress*15),
		randf_range(-progress_bar.progress*15, progress_bar.progress*15)
	);
	
	if progress_bar.progress == 1.0:
		GlobalOptions.reset_settings();
		Sound.playAudio("confirmMenu");
		progress_bar.progress = 0.0;
		

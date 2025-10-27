extends CanvasLayer

@onready var fps_text = $"fpsText";

func _process(delta: float) -> void:
	fps_text.visible = GlobalOptions.show_fps;
	fps_text.text = "FPS: %s"%[Engine.get_frames_per_second()];
	
	#var mem_usage = snapped(float(Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)), 0.01);
	#var mem_peak = snapped(float(Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / (1024 * 1024)), 0.01);
	#fps_text.text += str("\nMEMORY: ", mem_usage, " MB / ", mem_peak, " MB");
	

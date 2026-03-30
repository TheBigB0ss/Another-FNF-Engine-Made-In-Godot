extends CanvasLayer

@onready var fps_text = $"fpsText";
var mem_usage = 0;
var mem_peak = 0;
var curr_mem = 0;

func _process(delta: float) -> void:
	fps_text.visible = GlobalOptions.show_fps;
	fps_text.text = "FPS: %s"%[int(Engine.get_frames_per_second())];
	
	#curr_mem = OS.get_static_memory_usage();
	#if curr_mem != 0:
	#	mem_usage = curr_mem / 1048576.0;
	#	mem_peak = max(mem_peak, mem_usage);
		
	#fps_text.text += str("\nMEMORY: ", snapped(mem_usage, 0.01), " MB / ", snapped(mem_peak, 0.01), " MB");

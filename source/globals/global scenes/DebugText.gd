extends CanvasLayer

@onready var debugText = $"text";

var mem_usage = 0;
var mem_peak = 0;
var curr_mem = 0;

func _process(_delta: float) -> void:
	debugText.visible = (GlobalOptions.debugTextMode != "disable");
	debugText.text = "FPS: %s"%[int(Engine.get_frames_per_second())];
	
	var fps = int(Engine.get_frames_per_second());
	if GlobalOptions.debugTextMode == "complex":
		debugText.text = "FPS: %s\nVRAM: %s MB"%[fps, round((Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 104857.6)) / 10];
	else:
		debugText.text = "FPS: %s"%[fps];
		
	if OS.is_debug_build():
		curr_mem = OS.get_static_memory_usage();
		if curr_mem > 0:
			mem_usage = curr_mem / 1048576.0;
			mem_peak = max(mem_peak, mem_usage);
			debugText.text += str("\nMEMORY: ", snapped(mem_usage, 0.01), " MB / ", snapped(mem_peak, 0.01), " MB");
			

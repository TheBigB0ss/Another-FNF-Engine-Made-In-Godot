extends CanvasLayer

@onready var debugText = $"text";

var mem_usage = 0;
var mem_peak = 0;
var curr_mem = 0;

func _process(_delta: float) -> void:
	debugText.visible = (GlobalOptions.debugTextMode != "disable");
	
	var fps = int(Engine.get_frames_per_second());
	if GlobalOptions.debugTextMode == "complex":
		var vram = round((Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 104857.6)) / 10;
		var process_time = Performance.get_monitor(Performance.TIME_PROCESS);
		var scene_name = get_tree().current_scene.scene_file_path.get_file().get_basename() if get_tree().current_scene != null else "";
		
		debugText.text = "FPS: %s\nVRAM: %s MB\nPROCESS: %s ms\nSCENE: %s"%[fps, vram, process_time * 1000.0, scene_name];
	else:
		debugText.text = "FPS: %s"%[fps];
		
	if OS.is_debug_build():
		curr_mem = OS.get_static_memory_usage();
		if curr_mem > 0:
			mem_usage = curr_mem / 1048576.0;
			mem_peak = max(mem_peak, mem_usage);
			debugText.text += str("\nMEMORY: ", snapped(mem_usage, 0.01), " MB / ", snapped(mem_peak, 0.01), " MB");
			

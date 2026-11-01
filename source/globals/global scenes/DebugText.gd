extends CanvasLayer

@onready var debugText = $"text";

var mem_usage = 0;
var mem_peak = 0;
var curr_mem = 0;

var memPeak = 0;
var vramPeak = 0;
var texturePeak = 0;

func _process(_delta: float) -> void:
	debugText.visible = GlobalOptions.debugTextMode != "disable";
	
	if !debugText.visible:
		return
		
	update_text();
	
func update_text():
	var fps = Engine.get_frames_per_second();
	var objectMem = int(Performance.get_monitor(Performance.MEMORY_STATIC));
	var videoMem = int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED));
	var textureMem = int(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED));
	
	memPeak = maxi(memPeak, objectMem);
	vramPeak = maxi(vramPeak, videoMem);
	texturePeak = maxi(texturePeak, textureMem);
	
	var text = "FPS: %s"%[fps];
	
	if OS.is_debug_build():
		curr_mem = OS.get_static_memory_usage();
		if curr_mem > 0:
			mem_usage = curr_mem / 1048576.0;
			mem_peak = max(mem_peak, mem_usage);
			text += str("\nMEMORY: ", snapped(mem_usage, 0.01), " MB / ", snapped(mem_peak, 0.01), " MB");
			
	if GlobalOptions.debugTextMode == "complex":
		text += "\nPROCESS: %.2f ms"%[Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0];
		text += "\nVRAM: %s / %s" % [String.humanize_size(videoMem), String.humanize_size(vramPeak)];
		text += "\nTEX: %s / %s" % [String.humanize_size(textureMem), String.humanize_size(texturePeak)];
		
	debugText.text = text;
	

extends CanvasLayer

@onready var volume_bar = $'Control/volume_bar';
var muted_ = false;
var timer = Timer.new();

func _ready():
	timer.wait_time = 1.0;
	timer.process_mode = Node.PROCESS_MODE_ALWAYS;
	add_child(timer);
	timer.connect("timeout", hide_volume_button);
	
	if Global.volume < 0.1 or Global.volume == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true);
	elif Global.volume >= 0.1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false);
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), lerp(-20.0, 0.0, Global.volume));
		
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed:
			if ev.keycode in [Global.get_key("equal")]:
				volume_shit(Global.volume + 0.1);
				
			if ev.keycode in [Global.get_key("minus")]:
				volume_shit(Global.volume - 0.1);
				
func volume_shit(volume_value, muted = false):
	timer.start();
	show_volume_button();
	
	Global.volume = clamp(volume_value, 0.0, 1.0);
	
	if Global.volume < 0.1 or Global.volume == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true);
		
	elif Global.volume >= 0.1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false);
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), lerp(-20.0, 0.0, Global.volume));
		
	for i in volume_bar.get_children():
		if i.value <= Global.volume:
			i.modulate.a = 1;
		else:
			i.modulate.a = 0;
			
	GlobalOptions.get_setting("volume", Global.volume);
	
func show_volume_button():
	var tween = get_tree().create_tween();
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property($'Control', "position:y", 185, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
func hide_volume_button():
	var tween = get_tree().create_tween();
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property($'Control', "position:y", -110, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN);

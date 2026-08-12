class_name VocalManager extends Node

var vocals = [];
var volume_db = 0.0:
	set(val):
		volume_db = val;
		for i in vocals:
			i.volume_db = val;
			
var stream_paused = false:
	set(val):
		stream_paused = val;
		for i in vocals:
			i.stream_paused = val;
			
func play(new_pos = 0.0):
	for i in vocals:
		i.play(new_pos);
		
func stop():
	for i in vocals:
		i.stop();
		
func seek(new_pos = 0.0):
	for i in vocals:
		i.seek(new_pos);

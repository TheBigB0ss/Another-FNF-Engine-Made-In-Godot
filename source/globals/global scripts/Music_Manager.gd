extends AudioStreamPlayer

var music_loop = false;

func _play_song(to_load, path, loop, volume = 0.0, mode = PROCESS_MODE_INHERIT):
	stream = load("res://assets/%s/%s.ogg"%[path, to_load]);
	volume_db = volume;
	music_loop = loop;
	process_mode = mode;
	
	play(0.0);
	
func _process(_delta: float) -> void:
	if !playing && !music_loop:
		return;
		
	var songPos = get_playback_position();
	var songTime = stream.get_length();
	
	if floor(songPos) >= floor(songTime):
		play(0.0);
		
func _stop_music():
	stop();

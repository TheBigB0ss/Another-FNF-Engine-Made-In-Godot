extends AudioStreamPlayer2D

var music_loop = false;

func _play_music(to_load, music_top_level, loop, volume = 0.0):
	stream = load("res://assets/music/%s.ogg"%[to_load]);
	top_level = music_top_level;
	volume_db = volume;
	music_loop = loop;
	play(0.0);
	
func _play_song(to_load, music_top_level, loop, volume = 0.0):
	stream = load("res://assets/songs/%s.ogg"%[to_load]);
	top_level = music_top_level;
	volume_db = volume;
	music_loop = loop;
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

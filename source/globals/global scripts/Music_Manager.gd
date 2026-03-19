extends Node

var music = AudioStreamPlayer2D.new();
var cool_loop = false;

func _ready() -> void:
	add_child(music);
	
func _play_music(to_load, top_level, loop, volume = 0.0):
	music.stream = load("res://assets/music/%s.ogg"%[to_load]);
	music.top_level = top_level;
	music.volume_db = volume;
	cool_loop = loop;
	music.play(0.0);
	
func _play_song(to_load, top_level, loop, volume = 0.0):
	music.stream = load("res://assets/songs/%s.ogg"%[to_load]);
	music.top_level = top_level;
	music.volume_db = volume;
	cool_loop = loop;
	music.play(0.0);
	
func _process(delta: float) -> void:
	if !music.playing:
		return;
		
	if !cool_loop:
		return;
	var songPos = music.get_playback_position();
	var songTime = music.stream.get_length();
	if floor(songPos) >= floor(songTime):
		music.play(0.0);
		
func _stop_music():
	music.stop();

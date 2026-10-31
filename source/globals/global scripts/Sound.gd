extends Node

var audio:AudioStreamPlayer

func _ready() -> void:
	audio = AudioStreamPlayer.new();
	add_child(audio);
	
func playAudio(sound, isPixelAudio = false, volume = 0.0):
	var sound_name = sound + ("-pixel" if isPixelAudio else "");
	var path =  "res://assets/sounds/%s.ogg"%[sound_name];
	
	audio.stream = load(path);
	audio.volume_db = volume;
	audio.play();
	
func add_new_sound(sound, mode = Node.PROCESS_MODE_INHERIT, volume = 0.0):
	var new_audio = AudioStreamPlayer.new();
	
	new_audio.stream = load("res://assets/sounds/%s.ogg"%[sound]);
	new_audio.volume_db = volume;
	new_audio.process_mode = mode;
	
	add_child(new_audio);
	
	new_audio.finished.connect(func(): new_audio.queue_free());
	
	new_audio.play();
	
	return new_audio;
	
func stopAudio():
	audio.stop();
	

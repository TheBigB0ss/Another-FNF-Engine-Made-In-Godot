extends Node

var audio = AudioStreamPlayer.new();

func _ready():
	add_child(audio)
	
func playAudio(sound, isPixelAudio = false, volume = 0.0):
	audio.stream = load("res://assets/sounds/%s.ogg"%[sound + "-pixel" if isPixelAudio else sound]);
	audio.volume_db = volume;
	audio.play(0.0);
	
func add_new_sound(sound, mode = Node.PROCESS_MODE_INHERIT, volume = 0.0):
	var new_audio = AudioStreamPlayer.new();
	new_audio.stream = load("res://assets/sounds/%s.ogg"%[sound]);
	new_audio.volume_db = volume;
	new_audio.process_mode = mode;
	add_child(new_audio);
	new_audio.play(0.0);
	
	new_audio.connect("finished", Callable(self, "_on_sound_finished").bind(new_audio));
	
func _on_sound_finished(_audio):
	_audio.queue_free();
	
func stopAudio():
	audio.stop();

class_name VocalManager extends Node

static var instLength:float;
static var vocalsLength:float;
static var songLength:float;

static func load_audio(song, diff, inst, voices):
	var path = "res://assets/songs/%s/song/"%[song];
	var suffix = "-remix" if diff == "remix" else "";
	
	inst.stream = load(path + "Inst%s.ogg"%[suffix]);
	
	instLength = inst.stream.get_length();
	
	var player = path + "Voices-player%s.ogg"%[suffix];
	var opponent = path + "Voices-opponent%s.ogg"%[suffix];
	var vocals = path + "Voices%s.ogg"%[suffix];
	
	var vocalsSynchronized = AudioStreamSynchronized.new();
	
	if ResourceLoader.exists(player) && ResourceLoader.exists(opponent):
		vocalsSynchronized.stream_count = 2;
		vocalsSynchronized.set_sync_stream(0, load(player));
		vocalsSynchronized.set_sync_stream(1, load(opponent));
		
		vocalsLength = max(vocalsSynchronized.get_sync_stream(0).get_length(), vocalsSynchronized.get_sync_stream(1).get_length());
		
	else:
		vocalsSynchronized.stream_count = 1;
		vocalsSynchronized.set_sync_stream(0, load(vocals));
		
		vocalsLength = vocalsSynchronized.get_sync_stream(0).get_length();
		
	voices.stream = vocalsSynchronized;
	
	songLength = max(instLength, vocalsLength);
	

extends Node2D

@export_enum("Type1:1", "Type2:2") var spectrumType = 1;
@export var amount = 0.03;

@onready var vizu = $vizu;
@onready var speaker = $speaker;

var max_freq = 20000;
var min_db = -55;
var max_db = -3;
var song_spectrum:AudioEffectSpectrumAnalyzerInstance;

@export_range(1,5) var power = 3;

func _ready() -> void:
	Conductor.connect("new_beat", beat_hit);
	
	var analyzer = AudioEffectSpectrumAnalyzer.new();
	AudioServer.add_bus_effect(0, analyzer);
	song_spectrum = AudioServer.get_bus_effect_instance(0, 0);
	
	var index = 0;
	while (index < 6):
		vizu.get_child(index).play('VIZ%s'%[index+1])
		index += 1;
		
func beat_hit(beat):
	if beat % 2 == 0:
		speaker.play("ANIM_SPEAKER_Idle");
		
func _process(delta: float) -> void:
	if !song_spectrum:
		return;
		
	var count = vizu.get_child_count();
	for i in range(count):
		var low = lerp(20.0, float(max_freq), float(pow(float(i) / count, power)));
		var high = lerp(20.0, float(max_freq), float(pow(float(i + 1) / count, power)));
		
		var freq = song_spectrum.get_magnitude_for_frequency_range(low, high);
		var db = linear_to_db(freq.length());
		
		var value = clamp((db - min_db) / -min_db, 0.0, 1.0);
		value += (float(i) / count) * amount;
		value = clamp(value, 0.0, 1.0);
		
		match spectrumType:
			1:
				vizu.get_child(i).frame = 10 - int(floor(value * 10.0))
			2:
				vizu.get_child(i).frame = clamp(int(floor(value * 10.0)) + 1, 1, 10) - 1;

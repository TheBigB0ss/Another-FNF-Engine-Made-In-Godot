class_name FunkinScript extends Node

var game = ScriptLoader.game;

func _init() -> void:
	Conductor.new_beat.connect(beat_hit);
	Conductor.new_step.connect(step_hit);
	Conductor.change_section.connect(section_change);
	
func call_game_func(funcName, args = []):
	return ScriptLoader.call_game_func(funcName, args);
	
func get_game_var(variableName):
	return ScriptLoader.get_game_var(variableName);
	
func set_game_var(variableName, value):
	ScriptLoader.set_game_var(variableName, value);
	
func on_ready():
	pass;
	
func on_process(_delta):
	pass;
	
func step_hit(_step):
	pass;
	
func beat_hit(_beat):
	pass;
	
func section_change(_section):
	pass;
	
func on_song_end():
	pass;
	
func on_song_start():
	pass;
	
func on_note_created(_note:Note):
	pass;
	
func on_note_hit(_note:Note):
	pass;
	
func on_note_miss(_note:Note):
	pass;
	
func on_opponent_hit(_note:Note):
	pass;
	
func on_countdown(_tick):
	pass;
	
func on_event(_eventName, _args = []):
	pass;
	
func on_death_scene():
	pass;

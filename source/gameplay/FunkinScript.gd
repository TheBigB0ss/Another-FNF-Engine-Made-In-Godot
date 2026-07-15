class_name FunkinScript extends Node

var game = null;

func _init() -> void:
	Conductor.new_beat.connect(beat_hit);
	Conductor.new_step.connect(step_hit);
	Conductor.change_section.connect(section_change);
	
static func init_script(newGame, song = ""):
	var script_path = "res://assets/data/songs/%s/script.gd"%[song];
	if FileAccess.file_exists(script_path):
		var script = load(script_path);
		var new_script:FunkinScript = script.new();
		new_script.game = newGame;
		return new_script;
		
	var new_script = FunkinScript.new();
	new_script.game = newGame;
	return new_script;
	
func call_game_func(funcName = "", args = []):
	if game != null && game.has_method(funcName):
		return game.callv(funcName, args);
		
	return null;
	
func set_game_var(varName, newValue):
	if game != null:
		game.set(varName, newValue);
		
func get_game_var(varName):
	if game != null:
		return game.get(varName);
	return null;
	
func call_func(funcName := "", args := []):
	if has_method(funcName):
		return callv(funcName, args);
	return null;
	
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

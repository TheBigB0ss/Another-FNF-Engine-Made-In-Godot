class_name CharacterScript extends Node

var game = ScriptLoader.game;

func _init() -> void:
	Conductor.new_beat.connect(beat_hit);
	Conductor.new_step.connect(step_hit);
	Conductor.change_section.connect(section_change);
	
	Global.on_death_screen.connect(on_game_over);
	Global.on_death_confirm.connect(on_game_over_confirm);
	
static func init_character_script(character, parent):
	var script_path = "res://assets/data/characters/%s.gd"%[character];
	
	var current_script = null;
	var script = ResourceLoader.load(script_path);
	
	if script == null:
		return CharacterScript.new();
		
	current_script = script.new();
	
	parent.add_child(current_script);
	return current_script;
	
func call_game_func(funcName, args = []):
	return ScriptLoader.call_game_func(funcName, args);
	
func get_game_var(variableName):
	return ScriptLoader.get_game_var(variableName);
	
func set_game_var(variableName, value):
	ScriptLoader.set_game_var(variableName, value);
	
func call_func(funcName = "", args = []):
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
	
func on_sing(_anim):
	pass;
	
func on_dance():
	pass;
	
func on_game_over():
	pass;
	
func on_game_over_confirm():
	pass;
	
func on_miss(_note:Note):
	pass;
	
func on_note_hit(_note:Note):
	pass;

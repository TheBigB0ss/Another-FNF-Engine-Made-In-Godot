class_name Stage extends Node2D

var game = null;

func init_game(stage):
	game = stage;
	
func _init() -> void:
	Conductor.new_beat.connect(beat_hit);
	Conductor.new_step.connect(step_hit);
	
func step_hit(step) -> void:
	pass
	
func beat_hit(beat) -> void:
	pass
	
func call_func(funcName = "", args = []):
	if game.has_method(funcName):
		var func_call:Callable = Callable(game, funcName);
		func_call.callv(args);

extends Node

var game = null;
var current_script = null;

func init_script(newGame, song = "", diff = ""):
	if diff == "remix":
		if song.contains("remix"):
			song = song.replace("-remix", "");
			
	game = newGame
	var script_path = "res://assets/data/songs/%s/script%s.gd"%[song, str("-",diff) if diff != "" else ""];
	
	var script = ResourceLoader.load(script_path);
	
	if script == null:
		return FunkinScript.new();
		
	current_script = script.new();
	
	current_script.game = game;
	newGame.add_child(current_script);
	
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
	
func call_func(funcName = "", args = []):
	if current_script != null && current_script.has_method(funcName):
		return current_script.callv(funcName, args);
	return null;

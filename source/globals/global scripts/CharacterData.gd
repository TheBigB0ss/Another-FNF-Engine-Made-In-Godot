class_name CharacterData extends Node2D

var charData = {};

var charPath = '';
var animList = [];
var posesList = [];
var icon = '';

var healthColor = Color();

func _init() -> void:
	if Engine.is_editor_hint():
		return;
		
	Conductor.new_beat.connect(beat_hit);
	Conductor.new_step.connect(step_hit);
	
func step_hit(step) -> void:
	pass
	
func beat_hit(beat) -> void:
	pass
	
func init_json(path):
	var jsonFile = FileAccess.open(path, FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	charData = jsonData.get_data();
	jsonFile.close();

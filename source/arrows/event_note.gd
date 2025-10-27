extends "res://source/arrows/note/note.gd"

var value1 = "";
var value2 = "";
var event_name = "";

@onready var event_text = $"event texts";

func _ready():
	event_text.text = "%s\nval 1: %s\nval 2: %s"%[event_name, value1, value2];
	
	if sustainLenght > 0:
		sustainLenght = 0;

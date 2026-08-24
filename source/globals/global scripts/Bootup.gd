extends Node

var is_on_mobile:bool = true;

var touches:Dictionary[int, Vector2] = {}

func _ready() -> void:
	is_on_mobile = OS.get_name() == "Android" || OS.get_name() == "IOS";

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position;
		elif !event.pressed:
			touches.erase(event.index);
	
	elif event is InputEventScreenDrag:
		if touches[event.index]:
				touches[event.index] = event.position;

@tool

extends ColorRect
class_name TileButton

var inputs = [
	"left",
	"down",
	"up",
	"right"
]

@export var normal_color = Color.WHITE:
	set(v):
		normal_color = v;
		color = v;
		queue_redraw();

@export var pressed_color = Color.WHITE;

@export var key:String = "left";


var current_index = null;

var pressed:bool = false:
	set(v):
		var last_pressed = pressed;
		pressed = v;
		
		if last_pressed != pressed:
			color = pressed_color if pressed else normal_color;
			queue_redraw();
			_trigger(pressed);

func _validate_property(property: Dictionary) -> void:
	if property.name == "key":
		property.hint = PROPERTY_HINT_ENUM;
		property.hint_string = ",".join(inputs);

func is_hovered():
	for k in Bootup.touches.keys():
		var hovering = Bootup.touches[k] - position >= Vector2.ZERO && Bootup.touches[k] - position < size;
		if hovering:
			return true;
	return false;

func _process(delta: float) -> void:
	pressed = is_hovered();

func _trigger(isPressed:bool):
	var kp = GlobalOptions.get_key_input(inputs[inputs.find(key)]);
	if kp:
		get_viewport().gui_release_focus();
		kp.pressed = isPressed;
		kp.echo = false;
		Input.parse_input_event(kp);

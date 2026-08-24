@tool

extends TextureButton
class_name MobileButton

var inputs = {
	"enter": preload("res://assets/images/mobile/enterButton.png"),
	"escape": preload("res://assets/images/mobile/escButton.png"),
	"ui_up": preload("res://assets/images/mobile/upButton.png"),
	"ui_down": preload("res://assets/images/mobile/downButton.png"),
	"ui_left": preload("res://assets/images/mobile/leftButton.png"),
	"ui_right": preload("res://assets/images/mobile/rightButton.png")
}

var _simulating_press = false;

@export var key = "enter":
	set(v):
		key = v;
		texture_normal = inputs[key];

func _ready() -> void:
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS;

func _validate_property(property: Dictionary) -> void:
	if property.name == "key":
		property.hint = PROPERTY_HINT_ENUM;
		property.hint_string = ",".join(inputs.keys());

func _pressed() -> void:
	if !_simulating_press:
		var kp = GlobalOptions.get_key_input(inputs.keys()[inputs.keys().find(key)]);
		if kp:
			_simulating_press = true;
			
			get_viewport().gui_release_focus();
			
			kp.pressed = true;
			kp.echo = false;
			
			Input.parse_input_event(kp);
			
			await get_tree().process_frame;
			
			kp.pressed = false;
			Input.parse_input_event(kp);
			
			_simulating_press = false;

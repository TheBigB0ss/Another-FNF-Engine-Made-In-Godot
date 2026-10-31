@tool
class_name AlphabetObject extends Alphabet

@export_category("Text")

@export var text = "":
	set(value):
		text = value;
		coolText = value.to_upper();
		visible_letters = coolText.length();
		
@export var is_bold = true:
	set(value):
		is_bold = value;
		isBold = is_bold;
		_refresh_text();
		
@export var centred = false:
	set(value):
		centred = value;
		isCentered = centred;
		_refresh_text();
		
@export var visible_letters = 0:
	set(value):
		visible_letters = clampi(value, 0, coolText.length());
		visible_characters = visible_letters;
		
@export var allowSymbols = true:
	set(value):
		allowSymbols = value;
		useSymbols = allowSymbols;
		_refresh_text();
		
@export_category("Commands")

@export var makeShake = false:
	set(value):
		makeShake = value;
		shaking = value;
		
@export var makeWave = false:
	set(value):
		wave = value;
		makeWave = value;
		
@export var makeRainbow = false:
	set(value):
		makeRainbow = value;
		rainbow = makeRainbow;
		
@export var allowCommands = true:
	set(value):
		allowCommands = value;
		_refresh_text();
		
@export_category("Variables")

@export var shaking_intensity_x:float = 5.5:
	set(value):
		shaking_intensity_x = value;
		shakingX = shaking_intensity_x;
		
@export var shaking_intensity_y:float = 2.0:
	set(value):
		shaking_intensity_y = value;
		shakingY = shaking_intensity_y;
		
@export var wave_intensity:float = 10.0:
	set(value):
		wave_intensity = value;
		waveIntensity = wave_intensity;
		
@export var wave_speed:float = 5.0:
	set(value):
		wave_speed = value;
		waveSpeed = wave_speed;
		
@export var raindow_speed:float = 0.65:
	set(value):
		raindow_speed = value;
		rainbowSpeed = raindow_speed;
		
func _ready() -> void:
	shakingX = shaking_intensity_x;
	shakingY = shaking_intensity_y;
	waveIntensity = wave_intensity;
	waveSpeed = wave_speed;
	rainbowSpeed = raindow_speed;
	
	shaking = makeShake;
	wave = makeWave;
	useSymbols = allowSymbols;
	enable_commands = allowCommands;
	
func _refresh_text():
	_clear_word();
	do_a_word();
	

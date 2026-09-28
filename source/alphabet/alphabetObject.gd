@tool
class_name AlphabetObject extends Alphabet

@export var text = "":
	set(value):
		text = value;
		coolText = value.to_upper();
		visible_letters = len(coolText);
		
		_clear_word();
		do_a_word();
		
@export var is_bold = true:
	set(value):
		is_bold = value;
		isBold = is_bold;
		
		_clear_word();
		do_a_word();
		
@export var centred = false:
	set(value):
		centred = value;
		isCentered = centred;
		
		_clear_word();
		do_a_word();
		
@export var visible_letters = 0:
	set(value):
		value = clamp(value, 0, len(coolText));
		visible_letters = value;
		visible_characters = visible_letters;
		
		_clear_word();
		do_a_word();
		
@export var allowSymbols = true:
	set(value):
		allowSymbols = value;
		useSymbols = allowSymbols;
		
		_clear_word();
		do_a_word();

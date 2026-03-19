@tool
class_name AlphabetObject extends Alphabet

@export var text = "":
	set(value):
		text = value;
		coolText = value.to_upper();
		
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

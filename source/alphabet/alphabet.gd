class_name Alphabet extends Node2D

var coolText = "";
var wordArray = [];

var letterAnim = [];
var letters = [];

var isBold = true;
var isCentered = false;
var useSymbols = true;

const ALPHABET_FRAMES = preload("res://assets/images/alphabet/alphabet.res");

var visible_characters:
	set(val):
		val = clamp(val, 0, coolText.length());
		visible_characters = val;
		
		visible = visible_characters > 0;
		
		_clear_word();
		do_a_word();
		
func _creat_word(text = ""):
	coolText = text.to_upper();
	visible_characters = len(coolText);
	
	_clear_word();
	do_a_word();
	
func do_a_word():
	if coolText.is_empty():
		return;
		
	var visible_letters = coolText.substr(0, visible_characters);
	wordArray = visible_letters.split("");
	
	var letter_index = 0;
	
	while letter_index < wordArray.size():
		if letter_index+1 < wordArray.size():
			if wordArray[letter_index] == "\\" && wordArray[letter_index+1] == "N":
				letterAnim.append("\\n");
				letter_index += 2;
				
				continue;
				
		if wordArray[letter_index] == ":" && useSymbols:
			var symbol_end = wordArray.find(":", letter_index + 1);
			if symbol_end != -1:
				var symbolName = coolText.substr(letter_index + 1, symbol_end - letter_index - 1);
				var newSymbol = set_letter(symbolName);
				letterAnim.append(newSymbol);
				
				letter_index = symbol_end + 1;
				
				continue;
				
		if wordArray[letter_index] == " ":
			letterAnim.append(" ");
			letter_index += 1;
			continue;
			
		var newLetter = set_letter(wordArray[letter_index]);
		letterAnim.append(newLetter);
		
		letter_index += 1;
		
	_create_a_letter(letterAnim, isCentered);
	
func set_letter(letter):
	match letter:
		"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z":
			return letter + (" bold" if isBold else " capital");
		"0","1","2","3","4","5","6","7","8","9":
			return ("bold" + letter if isBold else letter);
		"(":
			return "bold (" if isBold else "(";
		")":
			return "bold )" if isBold else ")";
		"*":
			return "bold *" if isBold else "*";
		"-":
			return "bold -" if isBold else "-";
		">":
			return "bold >" if isBold else ">";
		"<":
			return "bold <" if isBold else "<";
		"!":
			return "EXCLAMATION POINT bold" if isBold else "exclamation point";
		"?":
			return "QUESTION MARK bold" if isBold else "question mark";
		"\'":
			return "APOSTRAPHIE bold" if isBold else "apostraphie";
		"&":
			return "bold &" if isBold else "amp";
		"$":
			return "dollarsign";
		"/":
			return "forward slash";
		"#":
			return "hashtag";
		".":
			return "PERIOD bold" if isBold else "period";
		"❤️", "HEART":
			return "heart";
		"←", "LEFT":
			return "left arrow";
		"→", "RIGHT":
			return "right arrow";
		"↑", "UP":
			return "up arrow";
		"↓", "DOWN":
			return "down arrow";
		"ANGRY FACE":
			return "angry faic";
		_:
			return letter;
			
func _create_a_letter(letter, isCentredLetter):
	var letter_width = 50;
	var line_height = 70;
	var space = 35;
	
	var line_total_width = 0;
	var lines_total_width = [];
	
	if isCentredLetter:
		for i in letter.size():
			if letter[i] == "\\n":
				lines_total_width.append(line_total_width);
				line_total_width = 0;
				
			elif letter[i] == " ":
				line_total_width += space;
				
			else:
				line_total_width += letter_width;
				
	lines_total_width.append(line_total_width);
	
	var offsetX = 0;
	var offsetY = 0;
	var line_id = 0;
	
	if isCentredLetter:
		offsetX = -lines_total_width[line_id] / 2;
		
	for i in letter.size():
		var character = letter[i];
		
		if character == "\\n":
			line_id += 1;
			
			offsetY += line_height;
			offsetX = 0;
			
			if isCentredLetter:
				offsetX = -lines_total_width[line_id] / 2;
				
			continue;
			
		elif character == " ":
			offsetX += space;
			
			continue;
			
		var new_word = AnimatedSprite2D.new();
		new_word.sprite_frames = ALPHABET_FRAMES;
		new_word.name = character;
		new_word.position = Vector2(offsetX, offsetY);
		new_word.visible = ALPHABET_FRAMES.has_animation(character);
		
		if ALPHABET_FRAMES.has_animation(character):
			new_word.play(character);
			
		add_child(new_word);
		
		offsetX += letter_width;
		
		letters.append(new_word);
		
func _clear_word():
	letters.clear();
	letterAnim.clear();
	for i in get_children():
		remove_child(i);
		i.queue_free();
		
func get_letter(letterId):
	return letters[letterId];
	
func get_last_letter():
	return letters[letters.size()-1];
	
func get_first_letter():
	return letters[0];

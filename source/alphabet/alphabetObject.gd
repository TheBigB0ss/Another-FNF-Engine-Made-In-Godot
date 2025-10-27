extends Node2D

var wordArray = [];
var letterAnim = [];
@export var coolText = "";
@export var isBold = true;

func _ready():
	if coolText != "":
		coolText = coolText.to_upper();
		do_a_word();
		
func do_a_word():
	wordArray = coolText.split("");
	letterAnim.clear();
	
	for i in wordArray:
		if i == " ":
			letterAnim.append("space");
		else:
			var newLetter = set_letter(i);
			letterAnim.append(newLetter);
			
	_create_a_letter(letterAnim);
	
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
		"❤️":
			return "heart";
		"←":
			return "left arrow";
		"→":
			return "right arrow";
		"↑":
			return "up arrow";
		"↓":
			return "down arrow";
		"$":
			return "dollarsign";
		_:
			return letter;
			
func _create_a_letter(letter):
	var offSetShit = 0;
	var coolOffset = 55;
	var space = 40;
	for i in letter.size():
		if letter[i] == "space":
			offSetShit += space;
			continue;
			
		var new_word = AnimatedSprite2D.new();
		new_word.sprite_frames = preload("res://assets/images/alphabet/alphabet.res");
		new_word.position.x = offSetShit;
		new_word.play(letter[i]);
		add_child(new_word);
		
		offSetShit += coolOffset;
		
func _clear_word():
	letterAnim = []
	for i in get_children():
		remove_child(i);
		i.queue_free();

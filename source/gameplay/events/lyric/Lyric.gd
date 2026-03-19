class_name Lyric extends RichTextLabel

var steps = [];
var syllables = [];
var new_curStep = 0.0;
var syllablesLenght = 0.0;
var base_pos = Vector2.ZERO;
var new_text = "";

func _ready() -> void:
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	modulate = Color(1, 1, 1);
	visible = true;
	bbcode_enabled = true;
	
	var font:FontFile = load("res://assets/fonts/vcr.ttf");
	add_theme_font_override("normal_font", font);
	add_theme_color_override("default_color", Color.WHITE);
	
	var blackBg = ColorRect.new();
	blackBg.z_index = -1;
	blackBg.color = Color(0, 0, 0, 0.6);
	add_child(blackBg);
	
	var new_text_size = font.get_string_size(text);
	blackBg.size = new_text_size + Vector2(40, 20);
	blackBg.position = (size / 2) - (blackBg.size / 2);
	blackBg.position.y -= 50;
	
var space_split = false;
func set_new_text(cool_text, new_steps):
	if cool_text == "":
		clearLyrics();
		return;
		
	new_text = cool_text;
	text = new_text;
	
	if new_text.contains("::"):
		syllables = new_text.split("::");
		space_split = false;
	else:
		syllables = new_text.split(" ");
		space_split = true;
		
	steps = new_steps;
	syllablesLenght = syllables.size()-1;
func _process(_delta: float) -> void:
	new_curStep = Conductor.curStep;
	
	if steps.is_empty():
		return;
		
	var step = 0;
	for i in steps.size():
		if new_curStep >= steps[i]:
			step += 1;
			
	var updated_text = "";
	for j in syllables.size(): 
		var separator = " " if space_split else "";
		if j == step:
			updated_text += "[color=red]" + syllables[j] + "[/color]"+separator; 
		else:
			updated_text += syllables[j]+separator;
			
	text = updated_text;
	
	if step > syllablesLenght:
		clearLyrics();
		
func clearLyrics():
	steps = [];
	syllables = [];
	syllables = 0.0;
	new_curStep = 0.0;
	self.queue_free();

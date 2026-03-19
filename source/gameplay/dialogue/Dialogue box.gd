extends CanvasLayer

@onready var the_box = $Box;
@onready var box_text = $Label;

@onready var opponentGrp = $'opponent';
@onready var bfGrp = $'boyfriend';
@onready var gfGrp = $'girlfriend'

@onready var cool_hand = $hand;

var bf = null;
var gf = null;
var opponent = null;

var dialogue_spr = "";
var box_pixel_part = "";
var is_pixel_box = true;
var curSong = "";
var cur_dialogue = 0;

var dialogue_array = [];
var characters_array = [];
var characters_spr_array = [];

func _ready():
	curSong = SongData.song;
	
	if FileAccess.file_exists("res://assets/data/songs/%s/%sDialogue.txt"%[curSong, curSong]):
		for i in getTxt().size():
			if getTxt()[i][0] != "":
				characters_array.append(getTxt()[i][0]);
				characters_spr_array.append(getTxt()[i][1]);
				dialogue_array.append(getTxt()[i][2]);
				
	elif FileAccess.file_exists("res://assets/data/songs/%s/%sDialogue.json"%[curSong, curSong]):
		for i in get_json_text()["structure"].size():
			characters_array.append(get_json_text()["structure"][i]["role"]);
			characters_spr_array.append(get_json_text()["structure"][i]["character"]);
			dialogue_array.append(get_json_text()["structure"][i]["text"]);
			
	the_box.position = Vector2(640, 415);
	box_text.position = Vector2(150, 465);
	
	box_text.visible_characters = 0;
	is_pixel_box = SongData.isPixelStage;
	
	if is_pixel_box:
		the_box.scale = Vector2(5.4, 5);
		the_box.texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
		box_pixel_part = "pixel";
	else:
		cool_hand.hide();
		the_box.position = Vector2(650, 535);
		box_text.position = Vector2(120, 490);
		box_text.modulate = Color("#000000");
		box_pixel_part = "default";
		
	match curSong:
		"senpai", "roses":
			box_text.modulate = Color("#692727");
			box_text.add_theme_color_override("font_shadow_color", Color("#4a1717"));
			box_text.add_theme_constant_override("shadow_offset_x", 2);
			box_text.add_theme_constant_override("shadow_offset_y", 2);
			
			if !is_joke_dialogue:
				MusicManager._play_music("Lunchbox", false, true, 1);
				
		"thorns":
			cool_hand.hide();
			opponentGrp.position = Vector2(220, 240);
			MusicManager._play_music("LunchboxScary", false, true, 1);
			
		_:
			MusicManager._play_music(GlobalOptions.updated_pause_music, false, true);
			
	if is_pixel_box:
		match curSong:
			"roses":
				dialogue_spr = "dialogueBox-senpaiMad" if !is_joke_dialogue else "dialogueBox-pixel";
				
			"thorns":
				dialogue_spr = "dialogueBox-evil";
				
			_:
				dialogue_spr = "dialogueBox-pixel";
	else:
		dialogue_spr = "Ballon";
		
	the_box.sprite_frames = load("res://assets/images/portraits/dialogue box/%s/%s.res"%[box_pixel_part, dialogue_spr]);
	
	if !dialogue_array.is_empty() && !characters_array.is_empty() && !characters_spr_array.is_empty():
		update_text(dialogue_array[cur_dialogue], characters_array[cur_dialogue], characters_spr_array[cur_dialogue]);
		
	if curSong == "senpai" && is_joke_dialogue:
		MusicManager._play_music("friend inside me", false, true, 1);
		
var is_joke_dialogue = false;
func getTxt():
	var txtData = [];
	var txtTexts = [];
	var path_file = "res://assets/data/songs/%s/%sDialogue.txt"%[curSong, curSong];
	
	match curSong:
		"senpai", "roses", "thorns":
			if is_joke() <= 6:
				is_joke_dialogue = true;
				path_file =  "res://assets/data/songs/%s/%sDialogue-joke.txt"%[curSong, curSong];
			else:
				is_joke_dialogue = false;
				
	var readTxt = FileAccess.open(path_file, FileAccess.READ);
	txtData = readTxt.get_as_text().split("\n");
	
	for i in txtData:
		var coolest_split = i.split("::");
		txtTexts.append(coolest_split);
		
	return txtTexts;
	
func get_json_text():
	var dialogue_data = {};
	
	var path_file = "res://assets/data/songs/%s/%sDialogue.json"%[curSong, curSong];
	var jsonFile = FileAccess.open(path_file, FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	dialogue_data = jsonData.get_data();
	jsonFile.close();
	
	return dialogue_data;
	
func is_joke():
	return int(randf_range(0, 3000));
	
func _process(delta):
	dialogue_timer += 1*delta;
	if dialogue_timer >= 0.05 && !SongData.is_not_in_cutscene && !Global.is_on_video:
		if box_text.visible_characters <= len(box_text.text):
			box_text.visible_characters += 1;
			dialogue_timer = 0;
			if characters_spr_array[cur_dialogue] != "evilLeafy":
				Sound.playAudio("pixelText", false);
				
		if is_pixel_box:
			cool_hand.visible = (box_text.visible_characters >= len(box_text.text));
			
	if Input.is_action_just_pressed("ui_accept") && !SongData.is_not_in_cutscene && box_text.visible_characters-1 < len(box_text.text):
		box_text.visible_characters = len(box_text.text);
		
	if Input.is_action_just_pressed("ui_accept") && !SongData.is_not_in_cutscene && box_text.visible_characters-1 == len(box_text.text):
		cur_dialogue += 1;
		Sound.playAudio("clickText", false);
		if !cur_dialogue > dialogue_array.size()-1:
			update_text(dialogue_array[cur_dialogue], characters_array[cur_dialogue], characters_spr_array[cur_dialogue]);
		else:
			start_song();
			
var dialogue_timer = 0;
var letter_count = 0;

func set_text(text):
	var new_text = "";
	for i in text:
		new_text += i;
		letter_count += 1;
		if letter_count % 48 == 0 && len(new_text) > 0:
			new_text += "\n";
			
	return new_text;
	
var dialogue_path = {
	"dad": "BallonLeft",
	"gf": "BallonBottom",
	"bf": "BallonRight"
};

func remove_chars(char):
	for i in char.get_children():
		i.queue_free();
		char.remove_child(i);
		
func update_text(text, char, char_spr):
	box_text.text = "";
	letter_count = 0;
	
	remove_chars(opponentGrp);
	remove_chars(bfGrp);
	remove_chars(gfGrp);
	
	match char_spr:
		"cowboy":
			opponentGrp.position = Vector2(285, 280);
			bfGrp.position = Vector2(1015, 280);
			gfGrp.position = Vector2(585, 280);
			
		"evilLeafy":
			opponentGrp.position = Vector2(285, 280);
			bfGrp.position = Vector2(1015, 280);
			gfGrp.position = Vector2(585, 280);
			Sound.playAudio("evilLeafy", false);
			
	if is_pixel_box:
		match curSong:
			"roses":
				the_box.play("SENPAI ANGRY IMPACT SPEECH instance 1" if !is_joke_dialogue else "Text Box Appear instance 1");
			"thorns":
				the_box.play("Spirit Textbox spawn instance 1");
			_:
				the_box.play("Text Box Appear instance 1");
				
	if dialogue_spr == "Ballon":
		the_box.play(dialogue_path[char]);
		
	match char:
		"dad":
			opponent = load("res://source/characters/dialogue portraits/%s.tscn"%[char_spr]).instantiate();
			opponentGrp.add_child(opponent);
			
			if char_spr == "spirit":
				opponent.is_trans = is_joke_dialogue;
				
			if curSong == "roses":
				opponentGrp.visible = is_joke_dialogue;
			else:
				opponentGrp.show();
				
			gfGrp.hide();
			bfGrp.hide();
			
		"bf":
			bf = load("res://source/characters/dialogue portraits/%s.tscn"%[char_spr]).instantiate();
			bfGrp.add_child(bf);
			
			gfGrp.hide();
			bfGrp.show();
			opponentGrp.hide();
			
		"gf":
			gf = load("res://source/characters/dialogue portraits/%s.tscn"%[char_spr]).instantiate();
			gfGrp.add_child(gf);
			
			gfGrp.show();
			bfGrp.hide();
			opponentGrp.hide();
			
	box_text.text = set_text(text);
	box_text.visible_characters = 0;
	
func start_song():
	MusicManager._stop_music();
	SongData.is_not_in_cutscene = true;
	Global.emit_signal("end_dialogue");
	get_tree().paused = false;
	self.hide();
	
func pause_song():
	self.show();

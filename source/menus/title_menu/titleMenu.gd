extends Node

var coolArray = [];
var no_spam = false;

var coolOffset = 0;

@onready var gf = $'tiltle stuff/Gf';
@onready var logo = $'tiltle stuff/logo';
@onready var new_logo = $'tiltle stuff/new logo';
@onready var enterText = $'tiltle stuff/title';
@onready var newGroundsLogo = $'tiltle stuff/NG Logo';
@onready var alphabets = $'alphabet_grp';
@onready var sales_man_bg = $'salesmanBg';
@onready var bambi = $"tiltle stuff/bnamb";

var hasSkippedIntro = false;
var gfDanceLeft = false;
var random_text_arr = [];

var datetime = Time.get_datetime_dict_from_system();

var salesMan1997 = false;

func _ready():
	Discord.update_discord_info("title menu", "Is in menus");
	
	if !Global.finished_intro:
		Conductor.getSongTime = 0.0;
		Global.connect("new_beat", beat_hit);
		
		hide_guys();
		MusicManager._play_music("freakyMenu", true, true);
	else:
		show_guys();
		Flash.flashAppears(1.3);
		
		Global.connect("new_beat", beat_hit);
		
	enterText.play("Press Enter to Begin");
	
	if datetime.month == 12 && datetime.day == 25:
		pass
		
	elif datetime.month == 10 && datetime.day == 31:
		pass
		
	random_text_arr = [getTxt()];
	
	salesMan1997 = (int(randf_range(0, 1997)) <= 97);
	if salesMan1997:
		newGroundsLogo.texture = preload("res://assets/images/title menu/pipis.png");
		
	sales_man_bg.visible = salesMan1997;
	
func _process(delta):
	new_logo.scale = lerp(new_logo.scale, Vector2(0.35, 0.35), 0.060);
	Conductor.getSongTime += delta*1000;
	
func show_guys():
	bambi.visible = (int(randf_range(0, 5000)) <= 5);
	if !bambi.visible:
		gf.visible = !salesMan1997;
		
	new_logo.show();
	enterText.show();
	
func hide_guys():
	gf.hide();
	new_logo.hide();
	enterText.hide();
	
func _input(ev):
	if Global.finished_intro:
		hasSkippedIntro = true;
		
	if hasSkippedIntro && !no_spam:
		if ev is InputEventKey && ev.pressed && (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]):
			no_spam = true;
			enterText.play("ENTER PRESSED");
			SoundStuff.playAudio('confirmMenu', false);
			Global.finished_intro = true;
			
			await get_tree().create_timer(1.5).timeout
			Global.changeScene("menus/main_menu/MainMenu", true, false);
			
	if ev is InputEventKey && ev.pressed && (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && !hasSkippedIntro && !Global.finished_intro:
		skipIntro();
		
func skipIntro():
	Flash.flashAppears(0.5);
	hideText();
	show_guys();
	newGroundsLogo.hide();
	hasSkippedIntro = true;
	
func getTxt():
	var txtData = [];
	var txtTexts = [];
	var readTxt = FileAccess.open("res://assets/data/IntroTexts.txt", FileAccess.READ);
	txtData = readTxt.get_as_text().split("\n");
	
	for i in txtData:
		var coolest_split = i.split("--");
		txtTexts.append(coolest_split);
		
	for i in txtTexts.size()-1:
		if (txtTexts[i][0] == "" && txtTexts[i][1] == ""):
			txtTexts.remove_at(i);
			
	var text = txtTexts.pick_random();
	if text[0] != "" && text[1] != "":
		return text;
		
	return ["no", "text"];
	
func create_text(text):
	var intro_texts = [];
	intro_texts.append(text);
	
	for i in intro_texts:
		var alphabet = Alphabet.new();
		alphabet.isCentered = true;
		alphabet._creat_word(i);
		alphabet.position.y += alphabets.get_child_count()*70;
		alphabet.position.x += 610;
		alphabets.add_child(alphabet);
		
func hideText():
	if alphabets.get_child_count() > 0:
		for i in alphabets.get_children():
			i.queue_free();
			
func beat_hit(beat):
	gfDanceLeft = !gfDanceLeft;
	new_logo.scale = Vector2(0.39, 0.39);
	gf.play("dance_right" if gfDanceLeft else "dance_left");
	logo.play("logo bumpin");
	
	if !hasSkippedIntro && !Global.finished_intro:
		match beat:
			1:
				create_text("big boss presents" if !salesMan1997 else "salesman1997 [presents]");
			4:
				hideText();
			5:
				create_text("not association" if !salesMan1997 else "any [association]");
				create_text("with");
			7:
				create_text("newgrounds" if !salesMan1997 else "[pipis]");
				newGroundsLogo.show();
			8:
				hideText();
				newGroundsLogo.hide();
			9:
				create_text(random_text_arr[0][0] if !salesMan1997 else "i have a special [deal]");
			10:
				create_text(random_text_arr[0][1] if !salesMan1997 else "just for you [%s]"%[Global.getUserName()]);
			11:
				hideText();
				newGroundsLogo.hide();
				$ameigos_bg.hide();
			12:
				create_text("another" if !salesMan1997 else "some one...");
			13:
				create_text("fnf engine" if !salesMan1997 else "please...........");
			14:
				create_text("made in godot" if !salesMan1997 else "........help");
			16:
				hideText();
				skipIntro();
				

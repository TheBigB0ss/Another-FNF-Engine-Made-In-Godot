extends Node

@onready var opts = $'creditsOpts';
@onready var socialOpts = $'socialOpts';

var coolOffset = 145;
var offSetShit = 0;

@onready var bg = $'Bg';

@onready var devName = $'Texts/name';
@onready var devRole = $'Texts/role';

var creditSelected = 0;
var socialSelected = 0;
var creditsJson = {};

var team = Alphabet.new();

func _ready():
	Discord.update_discord_info("credits menu", "Is in menus")
	
	var jsonFile = FileAccess.open("res://assets/data/credits_data.json" ,FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	creditsJson = jsonData.get_data();
	jsonFile.close();
	
	for i in creditsJson["dev_info"]:
		var icon = Sprite2D.new();
		icon.texture = load("res://assets/images/credits/icons/%s.png"%[i["icon"]]);
		icon.position.y = offSetShit;
		icon.position.x -= 40;
		opts.add_child(icon);
		offSetShit += coolOffset;
		
	team.scale = Vector2(0.55, 0.55);
	team.position = Vector2(20, 65);
	$Texts.add_child(team);
	
	opts.position.y = lerp(float(opts.position.y), float(480-coolOffset*creditSelected), 0.23);
	for j in creditsJson["dev_info"].size():
		opts.get_child(j).modulate.a = lerp(opts.get_child(j).modulate.a, (1.0 if j == creditSelected else 0.5), 0.20);
		opts.get_child(j).position.x = lerp(float(opts.get_child(j).position.x), float(150 if j == creditSelected else opts.position.x - 120), 0.25);
		
	changeDev(0);
	change_social_midia(0);
	
func _input(event):
	if event is InputEventKey:
		if event.pressed && !event.echo:
			if event.keycode in [Global.get_key("ui_down")]:
				changeDev(1);
				
			if event.keycode in [Global.get_key("ui_up")]:
				changeDev(-1);
				
			if len(creditsJson["dev_info"][creditSelected]["social midia"].keys()) > 0:
				if event.keycode in [Global.get_key("ui_left")]:
					change_social_midia(-1);
					
				if event.keycode in [Global.get_key("ui_right")]:
					change_social_midia(1);
					
				if (event.keycode in [Global.get_key("enter")] || event.keycode in [KEY_KP_ENTER]):
					open_link();
					
			if event.keycode in [Global.get_key("escape")]:
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
func changeDev(shit):
	creditSelected += shit;
	creditSelected = wrapi(creditSelected, 0, len(creditsJson["dev_info"]));
	Sound.playAudio("scrollMenu", false);
	
	change_social_midia(0);
	updateDev();
	
func change_social_midia(shit):
	socialSelected += shit;
	socialSelected = wrapi(socialSelected, 0, len(creditsJson["dev_info"][creditSelected]["social midia"].keys()));
	Sound.playAudio("scrollMenu", false);
	
	update_midia();
	
func update_social_icons():
	var social_offset = 165;
	var social_offset_shit = 0;
	
	for i in socialOpts.get_children():
		socialOpts.remove_child(i);
		i.queue_free();
		
	for i in creditsJson["dev_info"][creditSelected]["social midia"].keys():
		var social_icon = Sprite2D.new();
		social_icon.texture = load("res://assets/images/credits/social_midia/%s.png"%[i]);
		social_icon.position.x = social_offset_shit;
		social_icon.position.y -= 40;
		socialOpts.add_child(social_icon);
		social_offset_shit += social_offset;
		
func update_midia():
	update_social_icons();
	
	for i in len(creditsJson["dev_info"][creditSelected]["social midia"].keys()):
		if i == socialSelected:
			socialOpts.get_child(i).modulate.a = 1;
		else:
			socialOpts.get_child(i).modulate.a = 0.5;
			
func _process(delta):
	opts.position.y = lerp(float(opts.position.y), float(480-coolOffset*creditSelected), 0.23);
	for j in creditsJson["dev_info"].size():
		opts.get_child(j).modulate.a = lerp(opts.get_child(j).modulate.a, (1.0 if j == creditSelected else 0.5), 0.20);
		opts.get_child(j).position.x = lerp(float(opts.get_child(j).position.x), float(150 if j == creditSelected else opts.position.x - 120), 0.25);
		
	bg.modulate = lerp(bg.modulate, Color(creditsJson["dev_info"][creditSelected]["bg_color"]), 0.075);
	
func updateDev():
	devName.text = "";
	devRole.text = "";
	team._creat_word('');
	
	devName.text = creditsJson["dev_info"][creditSelected]["name"];
	devRole.text = creditsJson["dev_info"][creditSelected]["role"];
	team._creat_word(creditsJson["dev_info"][creditSelected]["team"]);
	
func open_link():
	OS.shell_open(creditsJson["dev_info"][creditSelected]["social midia"][creditsJson["dev_info"][creditSelected]["social midia"].keys()[socialSelected]]);

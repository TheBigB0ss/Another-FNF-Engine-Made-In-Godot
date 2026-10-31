extends Node

@onready var opts = $'creditsOpts';
@onready var socialOpts = $'socialOpts';

@onready var bg = $'Bg';

@onready var devName = $'Texts/name';
@onready var devRole = $'Texts/role';

var creditSelected = 0;
var socialSelected = 0;

var creditsJson = {};

var devInfo:
	get:
		return creditsJson["dev_info"][creditSelected];
		
var team = Alphabet.new();

func _ready():
	Discord.update_discord_info("credits menu", "Is in menus")
	
	creditsJson = Global.load_json("assets/data/credits_data");
	
	for i in creditsJson["dev_info"]:
		var icon = Sprite2D.new()
		icon.texture = load("res://assets/images/credits/icons/%s.png"%i["icon"])
		icon.position = Vector2(-40, opts.get_child_count() * 145.0)
		opts.add_child(icon);
		
	team.scale = Vector2(0.55, 0.55);
	team.position = Vector2(20, 65);
	$Texts.add_child(team);
	
	update_social_icons();
	
	creditSelected = Global.current_selected["credits"];
	
	updateDev();
	update_midia();
	
func _input(event):
	if !event is InputEventKey or !event.pressed or event.echo:
		return;
		
	if event.keycode == GlobalOptions.get_key("ui_down"):
		changeDev(1);
		
	elif event.keycode == GlobalOptions.get_key("ui_up"):
		changeDev(-1);
		
	elif event.keycode == GlobalOptions.get_key("ui_left"):
		change_social_media(-1);
		
	elif event.keycode == GlobalOptions.get_key("ui_right"):
		change_social_media(1);
		
	elif event.keycode == GlobalOptions.get_key("enter") or event.keycode == KEY_KP_ENTER:
		open_link();
		
	elif event.keycode == GlobalOptions.get_key("escape"):
		Global.changeScene("menus/main_menu/MainMenu", true, false);
		
func changeDev(change):
	creditSelected = wrapi(creditSelected + change, 0, creditsJson["dev_info"].size());
	
	Global.currentCredits = creditSelected;
	
	Sound.playAudio("scrollMenu", false);
	
	socialSelected = 0;
	
	update_social_icons();
	updateDev();
	update_midia();
	
func change_social_media(change):
	var socials = devInfo["social midia"];
	
	if socials.is_empty():
		return;
		
	socialSelected = wrapi(socialSelected + change, 0, socials.size());
	
	Sound.playAudio("scrollMenu", false);
	
	update_midia();
	
func update_social_icons():
	var socials = devInfo["social midia"];
	
	while socialOpts.get_child_count() < socials.size():
		var icon = Sprite2D.new();
		icon.scale = Vector2(0.70, 0.70);
		icon.position = Vector2(480 + (socialOpts.get_child_count() * 120.0), 480);
		socialOpts.add_child(icon);
		
	for i in socialOpts.get_child_count():
		var icon = socialOpts.get_child(i);
		
		if i < socials.size():
			icon.texture = load("res://assets/images/credits/social media/%s.png"%[socials.keys()[i]]);
			
		icon.visible = i < socials.size();
		
func update_midia():
	for i in socialOpts.get_child_count():
		var icon = socialOpts.get_child(i);
		icon.modulate.a = (1.0 if i == socialSelected else 0.5) if icon.visible else 0.0;
		
func _process(delta: float) -> void:
	opts.position.y = lerpf(opts.position.y, 480.0 - 145.0 * creditSelected, 1.0 - exp(-12.0 * delta));
	
	for i in opts.get_child_count():
		var icon = opts.get_child(i);
		
		icon.modulate.a = lerpf(icon.modulate.a, 1.0 if i == creditSelected else 0.5, 1.0 - exp(-6.0 * delta));
		icon.position.x = lerpf(icon.position.x, 150.0 if i == creditSelected else opts.position.x - 120.0, 1.0 - exp(-12.0 * delta));
		
	bg.modulate = bg.modulate.lerp(Color(devInfo["bg_color"]), 1.0 - exp(-6.0 * delta))
	
func updateDev():
	devName.text = devInfo["name"];
	devRole.text = devInfo["role"];
	
	team._creat_word(devInfo["team"]);
	
func open_link():
	var socials = devInfo["social midia"];
	
	if socials.is_empty():
		return;
		
	OS.shell_open(socials.values()[socialSelected]);

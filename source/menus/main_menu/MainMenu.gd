extends Node2D

var curOption = 0;
var options = ["storymode", "freeplay", "credits", "options"];
var noSpam = false;

@onready var coolOptions = $'options';
@onready var new_bg = $'TextureRect';
@onready var cool_bg = $'bg';

var coolOffset = 145;
var offSetShit = 0;

var you_delete_kenny = false;

func _ready():
	Discord.update_discord_info("main menu", "Is in menus");
	
	#var kenny_file = FileAccess;
	#var kenny_img = "res://assets/Kenny (don't delete he).png"
	#if kenny_file.file_exists(kenny_img):
	#	print("kenny exist")
	#	you_delete_kenny = false;
	#else:
	#	print("you kill him...")
	#	you_delete_kenny = true;
	
	get_tree().get_root().files_dropped.connect(drop_new_bg_image);
	
	for i in options:
		var menu_opts = load("res://assets/images/mainMenu/%s.tscn"%[i]).instantiate();
		menu_opts.play(i + " idle");
		menu_opts.position.y = offSetShit;
		menu_opts.position.x = -30;
		coolOptions.add_child(menu_opts);
		offSetShit += coolOffset;
		
	changeItem(0);
	
	coolOptions.position.y = float((720/2.0)-(coolOffset*curOption));
	
func drop_new_bg_image(file):
	var newBg_image = Image.new();
	newBg_image.load(file[0]);
	
	var newBg_texture = ImageTexture.new();
	newBg_texture.set_image(newBg_image);
	
	new_bg.texture = newBg_texture;
	new_bg.show();
	if new_bg.texture != null:
		cool_bg.hide();
		
var choiced = false;
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && !ev.echo && Global.can_use_menus:
			if ev.keycode in [Global.get_key("ui_down")] && !noSpam:
				changeItem(1);
				
			if ev.keycode in [Global.get_key("ui_up")] && !noSpam:
				changeItem(-1);
				
			if ev.keycode in [KEY_F5] && !noSpam:
				noSpam = true;
				Global.changeScene("/menus/achievements_menu/achievements_menu", true, false);
				
			if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !noSpam:
				noSpam = true;
				choiced = true;
				SoundStuff.playAudio("confirmMenu", false);
				
				await get_tree().create_timer(0.9).timeout;
				match options[curOption]:
					"storymode":
						Global.changeScene("/menus/story_mode/storyMode", true, false);
					"freeplay":
						Global.changeScene("/menus/freeplay/freeplay_menu", true, true);
					"credits":
						Global.changeScene("/menus/credits/credits", true, false);
					"options":
						Global.changeScene("/menus/options/options_menu", true, false);
						
			if ev.keycode in [Global.get_key("escape")] && !noSpam:
				noSpam = true;
				Global.changeScene("/menus/title_menu/titleMenu", true, false);
				Global.finished_intro = true;
				
var can_show_magenta = true;
var magenta_time = 0.095;
func _process(delta):
	coolOptions.position.y = lerp(float(coolOptions.position.y), float((720/2.0)-(coolOffset*curOption)), 0.040);
	if choiced:
		$magentaBg.show();
		magenta_time -= delta;
		if magenta_time <= 0:
			if can_show_magenta:
				$magentaBg.modulate.a = 1;
				can_show_magenta = false;
			else:
				$magentaBg.modulate.a = 0;
				can_show_magenta = true;
				
			magenta_time = 0.095;
			
func changeItem(change):
	curOption += change;
	curOption = wrapi(curOption, 0, len(options));
	
	for j in options.size():
		coolOptions.get_child(j).play(options[curOption] + " selected" if j == curOption else options[j] + " idle");
		
	SoundStuff.playAudio("scrollMenu", false);

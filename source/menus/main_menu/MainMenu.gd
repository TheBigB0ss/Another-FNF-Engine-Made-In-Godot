extends Node2D

var curOption = 0;
var options = ["storymode", "freeplay", "credits", "options"];
var noSpam = false;

@onready var coolOptions = $'options';
@onready var bg = $bgLayer/bg;
@onready var mangentaBg = $bgLayer/magentaBg;
@onready var alphabet_object = $achievementLayer/Control/AlphabetObject

var coolOffset = 145;
var offSetShit = 0;

func _ready():
	Discord.update_discord_info("main menu", "Is in menus");
	
	for i in range(0, len(options)):
		var menu_opts = AnimatedSprite2D.new();
		menu_opts.sprite_frames = load("res://assets/images/mainMenu/%s.res"%[options[i]]);
		menu_opts.play(options[i] + " idle");
		menu_opts.position.y = offSetShit;
		menu_opts.position.x = -30;
		coolOptions.add_child(menu_opts);
		if (Bootup.is_on_mobile): _create_option_hitbox(menu_opts, i);
		
		offSetShit += coolOffset;
		
	changeItem(Global.current_selected["mainmenu"]);
	
	if Bootup.is_on_mobile:
		coolOptions.position.y = 720-offSetShit;
	else:
		coolOptions.position.y = float((720/2.0)-(coolOffset*curOption));
	
	coolOptions.position.x = 50 + get_viewport_rect().size.x	/ 2.0;
	alphabet_object.position.x = coolOptions.position.x;

func _create_option_hitbox(menu_opts:AnimatedSprite2D, index:int):
	var area:Area2D = Area2D.new();
	var coll = CollisionShape2D.new();
	var shape = RectangleShape2D.new();
	shape.size = menu_opts.sprite_frames.get_frame_texture(options[index] + " idle", 0).get_size();
	coll.shape = shape;
	
	area.add_child(coll);
	area.input_event.connect(Callable(pressed_option).bind(index));
	
	menu_opts.add_child(area);

func confirm_option(opt:String):
	noSpam = true;
	choiced = true;
	Sound.playAudio("confirmMenu", false);
	
	await get_tree().create_timer(0.95).timeout;
	match opt:
		"storymode":
			Global.changeScene("/menus/story_mode/storyMode", true, false);
		"freeplay":
			Global.changeScene("/menus/freeplay/freeplay_menu", true, true);
		"credits":
			Global.changeScene("/menus/credits/credits", true, false);
		"options":
			Global.changeScene("/menus/options/options_menu", true, false);

func pressed_option(_viewport:Node, ev:InputEvent, _shape_idx:int, index:int):
	if ev is InputEventScreenTouch:
		if !noSpam && ev.pressed:
			if curOption == index:
				confirm_option(options[index]);
			else:
				SwitchItem(index);

var choiced = false;
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && !ev.echo && Global.can_use_menus:
			if ev.keycode in [GlobalOptions.get_key("ui_down")] && !noSpam:
				changeItem(1);
				
			if ev.keycode in [GlobalOptions.get_key("ui_up")] && !noSpam:
				changeItem(-1);
				
			if ev.keycode in [KEY_F5] && !noSpam:
				noSpam = true;
				Global.changeScene("/menus/achievements_menu/achievements_menu", true, false);
				
			if (ev.keycode in [GlobalOptions.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !noSpam:
				confirm_option(options[curOption]);
				
			if ev.keycode in [GlobalOptions.get_key("escape")] && !noSpam:
				noSpam = true;
				Global.changeScene("/menus/title_menu/titleMenu", true, false);
				Global.finished_intro = true;
				
var can_show_magenta = true;
var magenta_time = 0.095;
func _process(delta):
	if (!Bootup.is_on_mobile): coolOptions.position.y = lerp(coolOptions.position.y, (720/2.0)-(coolOffset*curOption), 1.0 - exp(-9.0 * delta));
	if !choiced:
		return;
		
	$magentaBg.show();
	magenta_time -= delta;
	if magenta_time <= 0:
		$magentaBg.modulate.a = 1.0 - $magentaBg.modulate.a;
		magenta_time = 0.095;

func SwitchItem(index:int):
	curOption = index;
	changeItem(0);

func changeItem(change):
	Sound.playAudio("scrollMenu", false);
	
	curOption += change;
	curOption = wrapi(curOption, 0, len(options));
	
	Global.currentMainMenu = curOption;
	
	for j in options.size():
		coolOptions.get_child(j).play(options[curOption] + " selected" if j == curOption else options[j] + " idle");
		

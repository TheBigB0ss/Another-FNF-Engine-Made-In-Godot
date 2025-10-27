extends CharacterData

@export var json_path = "";
@onready var character = $'character';

var animatedIcon = false;
var loopAnim = false;
var healthBar_Color = Color();
var curIcon = '';
var is_player = false;
var cam_follow_pos = false;
var curAnim = "";

var camera_pos = [];
var anim_offset = [];

var idleTimer = 0;
var anim_time = 5;

var song = "";

func _ready():
	charPath = json_path;
	
	Global.is_playing = false;
	
	song = Global.songsShit[0] if Global.isStoryMode else Global.songsShit;
	
	var jsonFile = FileAccess.open("res://assets/characters/%s.json"%[charPath],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	charData = jsonData.get_data()
	jsonFile.close();
	
	set_data_vars("camera follow pos", false);
	set_data_vars("AnimatedIcon", false);
	set_data_vars("LoopAnim", false);
	set_data_vars("cameraPos", [1, 1]);
	set_data_vars("scale", [1, 1]);
	set_data_vars("anim time", 5);
	
	character.scale = Vector2(charData["scale"][0], charData["scale"][1]);
	character.flip_h = charData["FlipX"];
	character.flip_v = charData["FlipY"];
	
	anim_time = charData["anim time"];
	curIcon = charData["HealthIcon"];
	animatedIcon = charData["AnimatedIcon"];
	healthBar_Color = Color(charData["HealthBarColor"]);
	loopAnim = charData["LoopAnim"];
	
	
	camera_pos = [charData["cameraPos"][0], charData["cameraPos"][1]]
	anim_time = charData["anim time"];
	is_player = charData["isPlayer"];
	curIcon = charData["HealthIcon"];
	animatedIcon = charData["AnimatedIcon"];
	healthBar_Color = Color(charData["HealthBarColor"]);
	loopAnim = charData["LoopAnim"];
	cam_follow_pos = charData["camera follow pos"];
	
	for i in charData["Poses"].size():
		animList.append(charData["Poses"][i]["Anim"]);
		posesList.append(charData["Poses"][i]["Name"]);
		
	_playAnim("dead")
	
	if Global.is_on_death_screen:
		if song == "ugh" or song == "guns" or song == "stress":
			var tankman_voice = AudioStreamPlayer.new();
			tankman_voice.stream = load("res://assets/sounds/game over/tankman gameover voice lines/jeffGameover-%s.ogg"%[choice_voice_line()]);
			add_child(tankman_voice);
			tankman_voice.play(0.0);
			
		SoundStuff.playAudio("game over/fnf_loss_sfx", false);
		if json_path == "Bf Pixel dead":
			SoundStuff.playAudio("game over/fnf_loss_sfx", true);
			
func set_data_vars(null_var, null_value):
	if !charData.has(null_var):
		charData[null_var] = null_value;
		
func choice_voice_line():
	return int(randi_range(1, 25));
	
func _process(delta):
	if curAnim.begins_with("dead") && curAnim != "dead loop" && Global.is_on_death_screen:
		idleTimer += delta;
		
	if idleTimer >= 2 && curAnim != "dead confirm" && Global.is_on_death_screen:
		bf_loop_anim();
		idleTimer = 0;
		
	if curAnim == "dead confirm" && idleTimer >= 2.5 && idleTimer < 2.6 && Global.is_on_death_screen:
		print("go back")
		idleTimer = 0;
		SongData.loadJson(Global.songsShit[0] if Global.isStoryMode else Global.songsShit, Global.diffsShit);
		Global.changeScene("gameplay/PlayState", true, false);
		
func _playAnim(anim):
	for i in animList.size():
		if animList[i] == anim:
			character.offset.x = charData["Poses"][i]["Offset"][0];
			character.offset.y = charData["Poses"][i]["Offset"][1];
			character.play(posesList[i]);
			character.frame = 0;
			
	curAnim = anim;
	
func bf_loop_anim():
	if Global.is_on_death_screen:
		MusicManager._play_music("game over/gameOver", false, true);
		
		if json_path == "Bf Pixel dead":
			MusicManager._play_music("game over/gameOver-pixel", false, true);
			
		_playAnim("dead loop");
		
var confirm = false;
func _input(ev):
	if ev is InputEventKey && Global.is_on_death_screen:
		if ev.pressed && !ev.echo && !confirm:
			if ev.keycode in [KEY_ENTER] && curAnim != "dead" && idleTimer == 0:
				MusicManager._play_music("game over/gameOverEnd", false, false);
				if json_path == "Bf Pixel dead":
					MusicManager._play_music("game over/gameOverEnd-pixel", false, true);
					
				_playAnim("dead confirm");
				confirm = true;
				
			if ev.keycode in [KEY_ESCAPE]:
				Global.is_on_death_screen = false
				Global.death_count = 0;
				MusicManager._stop_music();
				MusicManager._play_music("freakyMenu", true, true);
				Global.changeScene("menus/main_menu/MainMenu");
				confirm = true

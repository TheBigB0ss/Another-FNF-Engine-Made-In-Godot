extends CanvasLayer

@onready var options_grp = $'panel/options_grp';
@onready var text = $'panel/text';
@onready var pause_panel = $'panel';
@onready var timeText = $panel/timeText;

var paused = false;
var opts = ['RESUME', 'RESTART', 'BOTPLAY', 'OPTIONS', 'EXIT TO MENU'];
var cur_option = 0;
var can_use = false;
var is_paused = false;

var offSetShit = 0;
var coolOffset = 125;

@onready var main_scene = get_tree().current_scene;

func _ready():
	MusicManager._stop_music();
	SongData.isOnPauseMode = false;
	
	if SongData.isOnChartMode:
		opts.insert(3, "SKIP TIME");
		opts.insert(4, "EXIT CHART MODE");
		
	for i in opts:
		var pause_opts = Alphabet.new();
		pause_opts._creat_word(i);
		pause_opts.position.y = offSetShit;
		
		if SongData.isOnChartMode:
			pause_opts.position.y = offSetShit - 150;
			
		options_grp.add_child(pause_opts);
		offSetShit += coolOffset;
		
	var songName = SongData.song.to_upper();
	if songName.contains("-REMIX"):
		songName = songName.replace("-REMIX", "");
		
	text.text = "SONG: %s\nDIFFICULTY: %s\nDEATHS: %s"%[songName, SongData.week_diffs.to_upper() if SongData.week_diffs != "" else "NORMAL", SongData.death_count];
	
	for j in opts.size():
		if opts[j] == "BOTPLAY":
			options_grp.get_child(j).modulate = Color("#ffffff" if !GlobalOptions.isUsingBot else "#ffeb00");
			
	options_grp.position.y = float(480-coolOffset*cur_option);
	
	change_opt(0);
	
	is_paused = true;
	process_mode = 2;
	
func _process(_delta):
	MusicManager.volume_db = lerp(MusicManager.volume_db, 0.0, 0.005);
	options_grp.position.y = lerp(float(options_grp.position.y), float(480-coolOffset*cur_option), 0.20);
	
	if Global.can_use_menus:
		if Input.is_action_just_pressed("ui_accept") && !is_paused:
			_choice_pause_opts();
			is_paused = true;
			
		if Input.is_action_just_released("ui_accept"):
			is_paused = false;
			
	var curMinutes = str(int(curTime/1000) / 60).pad_zeros(1);
	var curSeconds = str(int(curTime/1000) % 60).pad_zeros(2);
	var maxMinutes = str(int(main_scene.inst.stream.get_length()) / 60).pad_zeros(1);
	var maxSeconds = str(int(main_scene.inst.stream.get_length()) % 60).pad_zeros(2);
	
	timeText.position = Vector2(options_grp.get_child(cur_option).position.x + 550, options_grp.get_child(cur_option).position.y + 80);
	timeText.visible = opts[cur_option] == "SKIP TIME";
	timeText.text = curMinutes + ":" + curSeconds + " / " + maxMinutes + ":" + maxSeconds;
	
var curTime = 0;
func _input(ev):
	if ev is InputEventKey:
		if can_use && Global.can_use_menus:
			if ev.pressed:
				if !ev.echo:
					if ev.keycode in [GlobalOptions.get_key("ui_down")]:
						change_opt(1);
						Sound.playAudio("scrollMenu", false);
						
					if ev.keycode in [GlobalOptions.get_key("ui_up")]:
						change_opt(-1);
						Sound.playAudio("scrollMenu", false);
						
				var rightKey = (ev.keycode == GlobalOptions.get_key("ui_right"));
				var leftKey = (ev.keycode == GlobalOptions.get_key("ui_left"));
				
				if opts[cur_option] == "SKIP TIME":
					var dir = int(rightKey) - int(leftKey);
					if dir != 0:
						curTime += dir*1000;
						curTime = clamp(curTime, 0, main_scene.inst.stream.get_length()*1000);
						
func change_opt(opt):
	cur_option += opt;
	cur_option = wrapi(cur_option, 0, len(opts));
	
	for i in opts.size():
		options_grp.get_child(i).modulate.a = (1 if i == cur_option else 0.5);
		
func _choice_pause_opts():
	match opts[cur_option]:
		"RESUME":
			_resume();
			can_use = false;
			
		"RESTART":
			paused = false;
			can_use = false;
			main_scene.inst.stop();
			main_scene.voices.stop();
			
			SongData.restartSong = true;
			SongData.isPlaying = false;
			Global.reloadScene(true, false);
			
		"OPTIONS":
			GlobalOptions.pause_options = true;
			paused = false;
			can_use = false;
			main_scene.inst.stop();
			main_scene.voices.stop();
			
			get_tree().paused = false;
			Global.changeScene("/menus/options/options_menu", true, false);
			SongData.isPlaying = false;
			
		"SKIP TIME":
			if curTime < main_scene.inst.get_playback_position()*1000:
				Conductor.startTime = curTime;
				Global.reloadScene(true, false);
			else:
				_resume();
				can_use = false;
				main_scene.setTimePos(curTime);
				
		"BOTPLAY":
			GlobalOptions.isUsingBot = !GlobalOptions.isUsingBot;
			for j in opts.size():
				if opts[j] == "BOTPLAY":
					options_grp.get_child(j).modulate = Color("#ffffff" if !GlobalOptions.isUsingBot else "#ffeb00");
					
			main_scene.updateScoreText();
			
		"EXIT TO MENU":
			paused = false;
			can_use = false;
			main_scene.inst.stop();
			main_scene.voices.stop();
			
			SongData.restartSong = false;
			SongData.isPlaying = false;
			SongData.isOnChartMode = false;
			SongData.death_count = 0;
			
			get_tree().paused = false;
			MusicManager._play_song("freakyMenu", "music", true);
			Global.changeScene("/menus/story_mode/storyMode" if SongData.isStoryMode else "/menus/freeplay/freeplay_menu");
			
		"EXIT CHART MODE":
			paused = false;
			can_use = false;
			main_scene.inst.stop();
			main_scene.voices.stop();
			
			SongData.restartSong = true;
			SongData.isOnChartMode = false;
			
			SongData.loadJson(SongData.week_songs[0], SongData.week_diffs, null);
			Global.reloadScene(true, false);
			
func stop_shit():
	paused = false;
	can_use = false;
	pause_panel.visible = false;
	
	get_tree().paused = false;
	main_scene.inst.stop();
	main_scene.voices.stop();
	
func _paused():
	if curTime != main_scene.inst.get_playback_position():
		curTime = main_scene.inst.get_playback_position()*1000;
		
	MusicManager._play_song(GlobalOptions.updated_pause_music, "music", true, -80.0);
	paused = true;
	pause_panel.visible = true;
	
func _resume():
	MusicManager._stop_music();
	paused = false;
	pause_panel.visible = false;
	get_tree().paused = false;
	

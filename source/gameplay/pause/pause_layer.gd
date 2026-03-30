extends CanvasLayer

@onready var options_grp = $'panel/options_grp';
@onready var song_text = $'panel/song_text';
@onready var difficulty_text = $'panel/difficulty_text';
@onready var pause_panel = $'panel';
@onready var death_count_text = $'panel/deaths';

var paused = false;
var opts = ['RESUME', 'RESTART', 'BOTPLAY', 'OPTIONS', 'EXIT TO MENU'];
var cur_option = 0;
var can_use = false;
var is_paused = false;

var offSetShit = 0;
var coolOffset = 125;

#var cool_arrow = Alphabet.new();

func _ready():
	song_text.text = "";
	difficulty_text.text = "";
	death_count_text.text = "";
	
	SongData.isOnPauseMode = false;
	
	if SongData.isOnChartMode:
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
		
	death_count_text.text += str("DEATHS: ",SongData.death_count);
	song_text.text += "SONG: %s"%[songName];
	difficulty_text.text += "DIFFICULTY: %s"%[SongData.week_diffs.to_upper() if SongData.week_diffs != "" else "NORMAL"];
	
	for j in opts.size():
		if opts[j] == "BOTPLAY":
			options_grp.get_child(j).modulate = Color("#ffffff" if !GlobalOptions.isUsingBot else "#ffeb00");
			
	options_grp.position.y = float(480-coolOffset*cur_option);
	
	change_opt(0);
	
	is_paused = true;
	process_mode = 2;
	
func _process(delta):
	MusicManager.music.volume_db = lerp(MusicManager.music.volume_db, 0.0, 0.005);
	options_grp.position.y = lerp(float(options_grp.position.y), float(480-coolOffset*cur_option), 0.20);
	
	if Global.can_use_menus:
		if Input.is_action_just_pressed("ui_accept") && !is_paused:
			_choice_pause_opts();
			is_paused = true;
			
		if Input.is_action_just_released("ui_accept"):
			is_paused = false;
			
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && !ev.echo && can_use && Global.can_use_menus:
			if ev.keycode in [Global.get_key("ui_down")]:
				change_opt(1);
				Sound.playAudio("scrollMenu", false);
				
			if ev.keycode in [Global.get_key("ui_up")]:
				change_opt(-1);
				Sound.playAudio("scrollMenu", false);
				
func change_opt(opt):
	cur_option += opt;
	cur_option = wrapi(cur_option, 0, len(opts));
	
	for i in opts.size():
		options_grp.get_child(i).modulate.a = 1 if i == cur_option else 0.5;
		
func _choice_pause_opts():
	match opts[cur_option]:
		"RESUME":
			_resume();
			can_use = false;
			
		"RESTART":
			paused = false;
			can_use = false;
			get_tree().current_scene.inst.stop();
			get_tree().current_scene.voices.stop();
			
			SongData.restartSong = true;
			SongData.isPlaying = false;
			Global.reloadScene(true, false, 3.5);
			
		"OPTIONS":
			GlobalOptions.pause_options = true;
			paused = false;
			can_use = false;
			get_tree().current_scene.inst.stop();
			get_tree().current_scene.voices.stop();
			
			Global.changeScene("/menus/options/options_menu", true, false);
			SongData.isPlaying = false;
			
		"BOTPLAY":
			GlobalOptions.isUsingBot = !GlobalOptions.isUsingBot;
			for j in opts.size():
				if opts[j] == "BOTPLAY":
					options_grp.get_child(j).modulate = Color("#ffffff" if !GlobalOptions.isUsingBot else "#ffeb00");
					
		"EXIT TO MENU":
			paused = false;
			can_use = false;
			get_tree().current_scene.inst.stop();
			get_tree().current_scene.voices.stop();
			
			SongData.restartSong = false;
			SongData.isPlaying = false;
			SongData.isOnChartMode = false;
			SongData.death_count = 0;
			
			MusicManager.music.process_mode = 0;
			MusicManager._play_music("freakyMenu", true, true);
			
			Global.changeScene("menus/story_mode/storyMode" if SongData.isStoryMode else "menus/freeplay/freeplay_menu");
			
		"EXIT CHART MODE":
			paused = false;
			can_use = false;
			get_tree().current_scene.inst.stop();
			get_tree().current_scene.voices.stop();
			
			SongData.restartSong = true;
			SongData.isOnChartMode = false;
			
			var default_chart = null;
			var songDiff = "" if SongData.week_diffs == "" else SongData.week_diffs;
			var song = SongData.week_songs[0];
			
			SongData.loadJson(song, songDiff, default_chart);
			Global.reloadScene(true, false, 3.5);
			
func stop_shit():
	paused = false;
	can_use = false;
	pause_panel.visible = false;
	
	get_tree().paused = false;
	get_tree().current_scene.inst.stop();
	get_tree().current_scene.voices.stop();
	
func _paused():
	MusicManager.music.process_mode = 2;
	MusicManager._play_music(GlobalOptions.updated_pause_music, true, true, -80.0);
	paused = true;
	pause_panel.visible = true;
	
func _resume():
	MusicManager.music.process_mode = 0;
	MusicManager._stop_music();
	paused = false;
	pause_panel.visible = false;
	get_tree().paused = false;

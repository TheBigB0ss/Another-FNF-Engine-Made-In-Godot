extends CanvasLayer

@onready var options_grp = $'panel/options_grp';
@onready var text = $'panel/text';
@onready var pause_panel = $'panel';
@onready var timeText = $panel/timeText;

var paused = false;
var opts = [
	'RESUME',
	'RESTART',
	'BOTPLAY',
	'OPTIONS', 
	'EXIT TO MENU'
];
var cur_option = 0;
var can_use = false;
var is_paused = false;

var botplay_option = null;

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
		pause_opts.position.y = offSetShit - (150 if SongData.isOnChartMode else 0);
		options_grp.add_child(pause_opts);
		
		if i == "BOTPLAY":
			botplay_option = pause_opts;
			
		offSetShit += coolOffset;
		
	var songName = SongData.song.to_upper().replace("-REMIX", "");
	text.text = "SONG: %s\nDIFFICULTY: %s\nDEATHS: %s" % [
		songName,
		SongData.week_diffs.to_upper() if SongData.week_diffs != "" else "NORMAL",
		SongData.death_count
	];
	
	update_botplay_color();
	
	options_grp.position.y = float(480-coolOffset*cur_option);
	
	change_opt(0);
	
	is_paused = true;
	#process_mode = 2
	pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS;
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
func _process(delta):
	MusicManager.volume_db = lerpf(MusicManager.volume_db, 0.0, 1.0 - exp(-0.35 * delta));
	
	options_grp.position.y = lerpf(options_grp.position.y, 480.0 - coolOffset * cur_option, 1.0 - exp(-9.0 * delta));
	
	if Global.can_use_menus and Input.is_action_just_pressed("ui_accept"):
		if !is_paused:
			is_paused = true
			_choice_pause_opts()
			
	if Input.is_action_just_released("ui_accept"):
		is_paused = false
		
	if opts[cur_option] == "SKIP TIME":
		var selected = options_grp.get_child(cur_option);
		
		timeText.position = selected.position + Vector2(550, 80);
		timeText.visible = true;
		
		update_time_text();
	else:
		timeText.visible = false;
		
var curTime = 0;
func _input(ev):
	if !ev is InputEventKey or !ev.pressed:
		return;
		
	if !can_use or !Global.can_use_menus:
		return;
		
	if ev.keycode == GlobalOptions.get_key("ui_down") && !ev.echo:
		change_opt(1);
		Sound.playAudio("scrollMenu", false);
		
	elif ev.keycode == GlobalOptions.get_key("ui_up") && !ev.echo:
		change_opt(-1);
		Sound.playAudio("scrollMenu", false);
		
	var rightKey = (ev.keycode == GlobalOptions.get_key("ui_right"));
	var leftKey = (ev.keycode == GlobalOptions.get_key("ui_left"));
	
	if opts[cur_option] == "SKIP TIME":
		var dir = int(rightKey) - int(leftKey);
		if dir != 0:
			curTime += dir*1000;
			curTime = clamp(curTime, 0, VocalManager.songLength*1000);
			
func change_opt(change):
	cur_option = wrapi(cur_option + change, 0, opts.size());
	
	for i in options_grp.get_child_count():
		var option = options_grp.get_child(i);
		option.modulate.a = 1.0 if i == cur_option else 0.5;
		
func _choice_pause_opts():
	match opts[cur_option]:
		"RESUME":
			_resume();
			can_use = false;
			
		"RESTART":
			stop_song();
			
			SongData.restartSong = true;
			SongData.isPlaying = false;
			
			Global.reloadScene(true, false);
			
		"OPTIONS":
			stop_song();
			
			GlobalOptions.pause_options = true;
			SongData.isPlaying = false;
			
			Global.changeScene("/menus/options/options_menu", true, false);
			
		"SKIP TIME":
			var current_position = max(Conductor.getSongTime, 0.0);
			
			can_use = false;
			
			if curTime < current_position:
				Conductor.startTime = curTime;
				Global.reloadScene(true, false);
				return;
				
			for strum in main_scene.game_strums.get_children():
				if strum.name == "Splashes":
					continue;
					
				for note in strum.noteNode.get_children():
					if note is Note:
						note.queue_free();
						
			clear_notes();
			main_scene.setTimePos(curTime);
			
			_resume();
			
		"BOTPLAY":
			GlobalOptions.isUsingBot = !GlobalOptions.isUsingBot;
			update_botplay_color();
			main_scene.updateScoreText();
			
		"EXIT TO MENU":
			stop_song();
			
			SongData.restartSong = false;
			SongData.isPlaying = false;
			SongData.isOnChartMode = false;
			SongData.death_count = 0;
			
			get_tree().paused = false;
			
			MusicManager._play_song("freakyMenu", "music", true);

			Global.changeScene("/menus/story_mode/storyMode" if SongData.isStoryMode else "/menus/freeplay/freeplay_menu");
			
		"EXIT CHART MODE":
			stop_song();
			
			SongData.restartSong = true;
			SongData.isOnChartMode = false;
			
			SongData.loadJson(SongData.week_songs[0], SongData.week_diffs, null);
			
			Global.reloadScene(true, false);
			
func stop_song():
	paused = false;
	can_use = false;
	
	main_scene.inst.stop();
	main_scene.voices.stop();
	
func _paused():
	if curTime != Conductor.getSongTime:
		curTime = Conductor.getSongTime;
		
	lastTime = -1;
	
	MusicManager._play_song(GlobalOptions.updated_pause_music, "music", true, -80.0);
	
	paused = true;
	pause_panel.visible = true;
	
func _resume():
	MusicManager._stop_music();
	
	paused = false;
	can_use = false;
	is_paused = true;
	
	pause_panel.visible = false;
	get_tree().paused = false;
	
func clear_notes():
	if is_instance_valid(main_scene.note_splashes):
		for i in main_scene.note_splashes.get_children():
			main_scene.note_splashes.remove_child(i);
			i.queue_free();
			
	for i in main_scene.game_strums.get_children():
		var splashes = i.get_node_or_null("Splashes");
		
		if splashes:
			for splash in splashes.get_children():
				splash.queue_free();
				
	for note in main_scene.playerStrum.notesList:
		if is_instance_valid(note.holdSplash):
			note.holdSplash.queue_free();
			
		note.holdSplash = null;
		
	for note in main_scene.opponentStrum.notesList:
		if is_instance_valid(note.holdSplash):
			note.holdSplash.queue_free();
			
		note.holdSplash = null;
		
	main_scene.playerStrum.playerNotes.clear();
	main_scene.opponentStrum.opponentNotes.clear();
	
var lastTime = -1;
func update_time_text():
	var seconds = int(curTime / 1000.0);
	
	if seconds == lastTime:
		return;
		
	lastTime = seconds;
	
	var current_minutes = seconds / 60;
	var current_seconds = seconds % 60;
	
	timeText.text = "%02d:%02d / %02d:%02d" % [current_minutes, current_seconds, int(VocalManager.songLength) / 60, int(VocalManager.songLength) % 60];
	
func update_botplay_color():
	if is_instance_valid(botplay_option):
		botplay_option.modulate = Color("#ffeb00" if GlobalOptions.isUsingBot else "#ffffff");
		

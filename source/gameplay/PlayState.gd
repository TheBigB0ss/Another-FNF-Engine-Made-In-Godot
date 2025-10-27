extends Node

@onready var cool_hud = $hud/Hud_Layer;
@onready var cool_strums = $strums/Strum_Layer;

@onready var timeText = $'hud/Hud_Layer/timeLabel';
@onready var ratingText = $'hud/Hud_Layer/ratingLabel'
@onready var scoreText = $'hud/Hud_Layer/scoreLabel';
@onready var timeBar = $"hud/Hud_Layer/timeBar";

var health = 50.0;

@onready var healthBar = $'hud/Hud_Layer/healthBar';

@onready var voices = $'voices';
@onready var inst = $'inst';

@onready var iconP1 = $'hud/Hud_Layer/icons/iconPlayer';
@onready var iconP2 = $'hud/Hud_Layer/icons/iconDad';
@onready var iconP3 = $'hud/Hud_Layer/icons/iconNewDad';
@onready var iconGrp = $'hud/Hud_Layer/icons';

@onready var animatedIconP1 = $"hud/Hud_Layer/animated icons/iconPlayer";
@onready var animatedIconP2 = $"hud/Hud_Layer/animated icons/iconDad";

@onready var song_card = $'hud/Hud_Layer/song card';

var ratingPart = "";
var ratings = ["sick", "good", "bad", "shit", "miss"];

@onready var rating_spr = $'rating/Rating_Layer/rating';
@onready var combo_spr = $'rating/Rating_Layer/combo';
@onready var nums_spr = $'rating/Rating_Layer/nums';

@onready var pause_menu = $'pause/Pause_Layer';
@onready var dialogue_box = $'dialogue/DialogueBox';

@onready var note_splshes = $'strums/Strum_Layer/Splashes';

var can_pause = false;

var is_in_winterHorrorland_cutscene = false;

var sicks = 0;
var goods = 0;
var bads = 0;
var shits = 0;

var combo = 0;
var score = 0;
var misses = 0;
var ratingName = '';
var rankName = '';

var totalHits = 0;
var notesPlayed = 0;
var percent = 0;

var isDead = false;

var bf = null;
var gf = null;
var dad = null;
var new_opponent = null;

@onready var stageGrp = $'stage';
var stage = null;

var is_on_intro = false;
var finished_song = false;

@onready var countdownSprite = $'hud/Hud_Layer/countdown';

var skipIntro = false;

@onready var noteGrp = $"notes/Note_Layer/Note_Grp";
@onready var playerStrum = $'strums/Strum_Layer/Player Notes';
@onready var opponentStrum = $'strums/Strum_Layer/Opponent Notes';
@onready var newOpponentStrum = $"strums/Strum_Layer/Second Opponent Note";

var notesList = [];
var playerNotes = [];
var opponentNotes = [];
var new_opponentNotes = [];

var array_notes = [];
var array_events_notes = [];

var curStage = "";
var curSong = "";

var playlist = [];
var songDiff = [];
var isStoryMode = false;

var singAnims = ["singLeft", "singDown", "singUp", "singRight"];

@onready var sectionCamera = $"Camera2D";

var camera_position = Vector2();
var camera_focus = false;
var camera_on_Bf = false;
var gf_is_singing = false;

@onready var botplayText = $'hud/Hud_Layer/botplayLabel';

var can_show_botplay = true;
var botplayTime = 0.60;

var countdownset = {
	"default": ['prepare', 'ready', 'set', 'go'],
	"pixel": ['prepare', 'ready', 'set', 'date']
};

var percentData = {
	"REALLY_BAD": ["Awful", 0.1],
	"VERY_BAD": ["Shit", 0.3],
	"JUST_BAD": ["Bad", 0.4],
	"MEH": ["Meh", 0.5],
	"IS_OKAY": ["Nice", 0.7],
	"IS_GOOD": ["Good", 0.8],
	"GREAT": ["Great!", 0.9],
	"VERY_GOOD": ["Sick!!", 1]
};

var rating_data = {
	"Shit": {
		"Ms": [175, 110],
		"Score": 20,
		"Percent": 0.10,
		"Rating": "shits",
		"RatingID": 3
	},
	"Bad": {
		"Ms": [110, 60],
		"Score": 80,
		"Percent": 0.40,
		"Rating": "bads",
		"RatingID": 2
	},
	"Good": {
		"Ms": [60, 30],
		"Score": 140,
		"Percent": 0.80,
		"Rating": "goods",
		"RatingID": 1
	},
	"Sick": {
		"Ms": [30, -140],
		"Score": 210,
		"Percent": 1,
		"Rating": "sicks",
		"RatingID": 0
	}
};

var achievements_map = {};

var splash_normal:PackedScene;
var splash_pixel:PackedScene;

func _ready():
	var achievementsJsonFile = FileAccess.open("res://assets/weeks/achievements_map.json", FileAccess.READ);
	var achievementsJsonData = JSON.new();
	achievementsJsonData.parse(achievementsJsonFile.get_as_text());
	achievements_map = achievementsJsonData.get_data();
	achievementsJsonFile.close();
	
	if get_tree().paused:
		get_tree().paused = false;
		
	pause_menu.visible = false;
	pause_menu.can_use = false;
	
	Global.connect("new_beat", beat_hit);
	Global.connect("new_step", step_hit);
	
	reset_status();
	
	isStoryMode = Global.isStoryMode;
	playlist = Global.songsShit;
	songDiff = Global.diffsShit;
	
	print("song list is: " + str(playlist));
	print("song diff is: " + str(songDiff));
	
	splash_normal = preload("res://source/arrows/splashes/noteSplashes.tscn");
	splash_pixel = preload("res://source/arrows/splashes/pixel/pixelNoteSplash.tscn");
	
	Global.is_on_death_screen = false;
	Global.is_playing = true;
	
	ratingText.visible = GlobalOptions.show_ratingLabel;
	
	GlobalOptions.connect("ghost_tapping_miss", miss_note);
	Achievements.connect("end_achievement", finishSong);
	Global.connect("noteMissed", miss_note);
	Global.connect("longNoteMissed", miss_note);
	Global.connect("longNoteReleased", miss_note);
	Global.connect("notePressed", pressedNote);
	Global.connect("end_dialogue", startCoutdown);
	Global.connect("end_cutscene", startCoutdown);
	Global.connect("eng_tankman_cutscene", startCoutdown);
	
	stage = load("res://source/stages/%s.tscn"%[SongData.stage]).instantiate();
	SongData.loadStageJson(SongData.stage);
	
	curSong = SongData.song;
	curStage = SongData.stage;
	
	var bf_position = SongData.player1StagePosition;
	var gf_position = SongData.gfStagePosition
	var opponent_position = SongData.gfStagePosition if SongData.player2 == "gf" else SongData.player2StagePosition;
	
	bf = add_character(bf, bf_position, SongData.player1Zindex, SongData.player1, 4);
	dad = add_character(dad, opponent_position, SongData.player2Zindex, SongData.player2, 3);
	gf = add_character(gf, gf_position, SongData.gfZindex, SongData.gfPlayer, 1);
	if SongData.player3 != "" && SongData.haveTwoOpponents:
		new_opponent = add_character(new_opponent, Vector2(dad.position.x + 150, dad.position.y), SongData.player2Zindex, SongData.player3, 2);
		
	stageGrp.add_child(stage);
	
	bf.character.flip_h = true if !bf.is_player else false;
	dad.character.flip_h = true if dad.is_player else false;
	
	if SongData.isPixelStage:
		countdownSprite.scale = Vector2(8,8);
		for i in [countdownSprite, rating_spr, combo_spr, nums_spr]:
			i.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST;
			
		ratingPart = '-pixel';
	else:
		ratingPart = '';
		
	healthBar.tint_under = Color("#ff000f") if GlobalOptions.updated_hud == "classic hud" else dad.healthBar_Color;
	healthBar.tint_progress = Color("#00ff06") if GlobalOptions.updated_hud == "classic hud" else bf.healthBar_Color;
	
	if bf.animatedIcon:
		add_animatedIcon(animatedIconP1, false, bf.curIcon);
	else:
		iconP1.texture = load("res://assets/images/icons/icon-%s.png"%[bf.curIcon]);
		animatedIconP1.hide();
		
	if dad.animatedIcon:
		add_animatedIcon(animatedIconP2, true, dad.curIcon);
	else:
		iconP2.texture = load("res://assets/images/icons/icon-%s.png"%[dad.curIcon]);
		animatedIconP2.hide();
		
	if SongData.player3 != "" && SongData.haveTwoOpponents:
		iconP3.texture = load("res://assets/images/icons/icon-%s.png"%[new_opponent.curIcon]);
		iconP3.show();
		
	for i in SongData.songNotes:
		for j in i["sectionNotes"]:
			array_notes.insert(0, [j[0], j[1], j[2], j[3], i["gfSection"], i["altAnim"], i["mustHitSection"], false]);
			
	if !SongData.songEvents.is_empty():
		for i in SongData.songEvents:
			array_events_notes.insert(0, [i[0], i[1], i[2], i[3], i[4]]);
			
	SongData.updated_chart = SongData.chartData;
	
	Conductor.mapBPMChanges(SongData.chartData);
	Conductor.changeBpm(SongData.songBpm);
	
	Conductor.getSongTime = -Conductor.crochet*5;
	Conductor.songSpeed = SongData.songSpeed;
	
	startSong();
	
	for i in [healthBar, iconP1, iconP2, iconP3, $"hud/Hud_Layer/animated icons"]:
		i.modulate.a = GlobalOptions.health_bar_alpha;
		
	for i in [timeBar, timeText]:
		i.modulate.a = GlobalOptions.time_bar_alpha;
		
	if GlobalOptions.hide_hud:
		for i in [$hud/Hud_Layer/healthBar, $hud/Hud_Layer/icons, $hud/Hud_Layer/scoreLabel, $hud/Hud_Layer/timeLabel, $hud/Hud_Layer/timeBar, $"hud/Hud_Layer/animated icons"]:
			i.hide();
			
	if GlobalOptions.down_scroll:
		$hud/Hud_Layer/healthBar.position.y = 60;
		$hud/Hud_Layer/icons/iconNewDad.position.y = 55;
		$hud/Hud_Layer/timeBar.position.y = 680;
		$hud/Hud_Layer/scoreLabel.position.y = 85;
		$hud/Hud_Layer/timeLabel.position.y = 675;
		
		for i in [playerStrum, opponentStrum]:
			i.position.y = 620;
			
		for i in [iconP1, iconP2, animatedIconP1, animatedIconP2]:
			i.position.y = 65;
			
	if GlobalOptions.middle_scroll:
		playerStrum.position.x = 478;
		opponentStrum.visible = false;
		
	if SongData.haveTwoOpponents:
		newOpponentStrum.show();
		newOpponentStrum.position = Vector2(550, 100) if !GlobalOptions.down_scroll else Vector2(550, 600);
		newOpponentStrum.modulate.a = 0.60;
		newOpponentStrum.visible = !GlobalOptions.middle_scroll;
	else:
		newOpponentStrum.hide();
		
	playerStrum.appearNOW = skipIntro;
	opponentStrum.appearNOW = skipIntro;
	
	if SongData.haveTwoOpponents:
		newOpponentStrum.appearNOW = skipIntro;
		
	for i in [iconP1, iconP2, iconP3]:
		set_icon_hframes(i);
		
	if isStoryMode && Global.death_count <= 0 && !Global.restartSong:
		match curSong:
			"winter-horrorland":
				is_in_winterHorrorland_cutscene = true;
				stage.winterHorrorland_cutscene();
			"ugh":
				stage.ugh_cutscene();
			"guns":
				stage.guns_intro();
			"stress":
				stage.stress_intro();
			"thorns":
				stage.start_cutscene();
				
	var txt_path = "res://assets/data/%s/%sDialogue.txt"%[curSong, curSong];
	var json_path = "res://assets/data/%s/%sDialogue.json"%[curSong, curSong];
	if FileAccess.file_exists(txt_path) or FileAccess.file_exists(json_path):
		if Global.death_count <= 0 && isStoryMode && !Global.restartSong:
			match curSong:
				"thorns":
					Global.connect("end_senpai_cutscene", start_dialogue);
				_:
					start_dialogue();
		else:
			startCoutdown();
	else:
		Global.is_not_in_cutscene = true;
		
	if Global.is_not_in_cutscene && !Global.is_on_video && !is_in_winterHorrorland_cutscene && !FileAccess.file_exists(txt_path):
		startCoutdown();
		
	if !is_in_winterHorrorland_cutscene:
		sectionCamera.zoom = SongData.stageZoom;
		
	if !is_in_winterHorrorland_cutscene && is_on_intro:
		move_cam(true if GlobalOptions.updated_cam == "smooth" else false, (dad.global_position + Vector2(dad.camera_pos[0], dad.camera_pos[1])*dad.scale));
		
	if GlobalOptions.show_songCard:
		song_card.show();
		var newCurSong = curSong;
		
		if newCurSong.contains("-remix"):
			newCurSong = newCurSong.replace("-remix", "");
			
		var path = "res://assets/images/song_cards/%s/songs/%s_card_text.png"%[SongData.week, newCurSong];
		var custom_path = '';
		var song_name = null;
		
		if ResourceLoader.exists(path, "Texture2D"):
			song_name = Sprite2D.new();
		else:
			song_name = Label.new();
			
		match curSong:
			"monster", "monster-remix", "winter-horrorland":
				custom_path = "-monster";
			"roses", "roses-remix":
				custom_path = "-roses";
			"thorns", "thorns-remix":
				custom_path = "-thorns";
				
		match SongData.week:
			"week6":
				song_card.texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
				song_name.texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
				
		var songCardPath = "res://assets/images/song_cards/%s/card_%s%s.png"%[SongData.week, SongData.week, custom_path];
		if ResourceLoader.exists(songCardPath, "Texture2D"):
			song_card.texture = load(songCardPath);
			
		if song_name is Sprite2D:
			var songPath = "res://assets/images/song_cards/%s/songs/%s_card_text.png"%[SongData.week, newCurSong];
			if ResourceLoader.exists(songPath, "Texture2D"):
				song_name.texture = load(songPath);
				
		elif song_name is Label:
			var font:FontFile = load("res://assets/fonts/vcr.ttf");
			
			song_name.text = curSong;
			song_name.position.x -= 30;
			song_name.add_theme_font_override("font", font);
			song_name.add_theme_color_override("font_shadow_color", Color.BLACK);
			song_name.add_theme_font_size_override("font_size", 64);
			
		song_card.add_child(song_name);
	else:
		song_card.hide();
		
	if GlobalOptions.updated_hud == "classic hud":
		timeBar.hide();
		timeText.hide();
		if !GlobalOptions.middle_scroll:
			playerStrum.position.x -= 75;
			
		newOpponentStrum.position.x -= 35;
		scoreText.text = 'Score: %s'%[score];
		scoreText.position.x = 765;
		scoreText.scale = Vector2(0.03, 0.03);
		
	updateScoreText();
	
func sort_notes(a, b):
	return a.strumTime < b.strumTime;
	
func remove_character(char_to_remove):
	remove_child(char_to_remove);
	char_to_remove.queue_free();
	
func add_character(char, position, z_index, path, child_pos):
	if path != "none":
		char = load("res://source/characters/" + path + ".tscn").instantiate();
		char.position = position;
		char.z_index = z_index;
		add_child(char);
		move_child(char, child_pos);
		
		return char;
		
func add_animatedIcon(grp, is_opponent, path):
	var new_icon = AnimatedIcon.new();
	new_icon.icon_frames = "assets/images/icons/animated/%s.res"%[path];
	new_icon.icon_char = path;
	grp.add_child(new_icon);
	if is_opponent:
		iconP2.hide();
	else:
		new_icon.flip_h = true;
		iconP1.hide();
		
func start_dialogue():
	Global.is_not_in_cutscene = false;
	dialogue_box.show();
	dialogue_box.pause_song();
	
func spawnNote(strumTime, noteData, lenght, type, isGfNote, isAltAnim, isPlayer):
	var note_data = int(noteData)%4;
	var is_a_player_note = isPlayer;
	var is_second_opponent = false;
	
	if noteData > 3 && noteData < 8:
		is_a_player_note = !isPlayer;
		
	if noteData >= 8 && SongData.haveTwoOpponents:
		isPlayer = false;
		is_a_player_note = false;
		is_second_opponent = true;
		
	var note = preload("res://source/arrows/note/note.tscn").instantiate();
	note.is_altAnim = isAltAnim;
	note.strumTime = strumTime;
	note.noteData = note_data;
	note.sustainLenght = lenght;
	note.type = type;
	note.isGfNote = isGfNote or (type == "gf sing");
	note.is_altAnim = isAltAnim or (type == "alt anim");
	note.no_anim = (type == "No Animation");
	note.is_hey_note = (type == "Hey!");
	note.isPlayer = is_a_player_note;
	note.secondOpponentNote = is_second_opponent;
	note.must_press = note.isPlayer;
	note.isSustain = note.sustainLenght > 0.0;
	
	var new_noteGrp;
	if note.must_press && is_a_player_note && note.isPlayer:
		new_noteGrp = playerStrum;
		playerNotes.append(note);
		
	if !is_a_player_note && !note.isPlayer:
		new_noteGrp = opponentStrum;
		note.visible = !GlobalOptions.middle_scroll;
		opponentNotes.append(note);
		
	if is_second_opponent && !is_a_player_note && !note.isPlayer:
		new_noteGrp = newOpponentStrum;
		note.visible = !GlobalOptions.middle_scroll;
		new_opponentNotes.append(note);
		
	var strum = new_noteGrp.get_child(note.noteData);
	var noteStrumY = new_noteGrp.position.y + strum.position.y;
	note.rotation = strum.rotation;
	note.modulate.a = strum.modulate.a;
	note.strumY = noteStrumY;
	note.position.x = new_noteGrp.position.x + strum.position.x;
	if note.note != null:
		note.note.offset = strum.note.offset;
		
	notesList.append(note);
	notesList.sort_custom(Callable(self, "sort_notes"));
	
	noteGrp.add_child(note);
	
func set_event(new_event, new_value1, new_value2):
	var event = new_event;
	var value1 = new_value1;
	var value2 = new_value2;
	
	trigger_event(event, value1, value2);
	
var appleCoreNotes = false;
var appleCoreStrumTime = 0;

func trigger_event(event_name, value1, value2):
	match event_name:
		"change song speed":
			Conductor.songSpeed = value1.to_float();
			
		"change song pitch":
			inst.pitch_scale = lerp(inst.pitch_scale, value1.to_float(), value2.to_float());
			voices.pitch_scale = lerp(voices.pitch_scale, value1.to_float(), value2.to_float());
			Conductor.songSpeed = lerp(Conductor.songSpeed, value1.to_float(), value2.to_float());
			
		"change character":
			changeCharacter(value1, value2);
			
		"change bg":
			changeBg(value1);
			
		"play anim":
			characterPlayAnim(value1, value2);
			
		"flash":
			Flash.flashAppears(value1.to_float(), Color(value2));
			
		"set camera position":
			set_new_camPos(value1, value2);
			
		"add cam zoom":
			sectionCamera.zoom = Vector2(value1.to_float(), value1.to_float());
			
		"spawn popUp":
			var new_popUp = preload("res://source/gameplay/events/pop ups/popUps.tscn").instantiate();
			$hud/Hud_Layer.add_child(new_popUp);
			
		"unfair note":
			appleCoreNotes = true;
			
		"set lyric":
			var string_steps = value2.split(",");
			var steps = [];
			for i in string_steps:
				steps.append(int(i));
				
			if value2 == "":
				steps = [];
				
			var newLyric = Lyric.new();
			newLyric.position = Vector2(350.0, 275.0);
			newLyric.position.y += 240;
			newLyric.set_size(Vector2(600, 100));
			newLyric.set_new_text(value1, steps);
			$hud/Hud_Layer.add_child(newLyric);
			
var notes_to_delete = [];
var opponents_strums = [];

var start_song = false;
var strumY = null;
var strumX = null;

var discord_songName = "";

func set_cool_animated_icon(icon, is_lerp):
	if icon.get_child_count() > 0:
		if is_lerp:
			icon.get_child(0).scale = lerp(icon.get_child(0).scale, Vector2(1.0, 1.0), 0.08);
		else:
			icon.get_child(0).scale = Vector2(1.2, 1.2);
			
var last_song_seek = 0.0;
func _process(delta: float) -> void:
	#for i in playerStrum.get_children():
	#	i.note.offset = Vector2(randf_range(10, 20), randf_range(10, 30))
		
	appleCoreStrumTime += delta;
	
	if start_song:
		if !pause_menu.paused:
			inst.stream_paused = false;
			voices.stream_paused = false;
			
			Conductor.getSongTime += (delta*1000);
			
			if !finished_song:
				var inst_pos = inst.get_playback_position();
				if abs(inst_pos - Conductor.getSongTime / 1000) > 0.03 && Time.get_ticks_msec() - last_song_seek > 500:
					inst.seek(Conductor.getSongTime / 1000);
					voices.seek(Conductor.getSongTime / 1000);
					last_song_seek = Time.get_ticks_msec();
		else:
			inst.stream_paused = true;
			voices.stream_paused = true;
			
	var helthLerpValue = lerp(float(healthBar.value), health, 0.40);
	healthBar.value = helthLerpValue;
	
	if Global.is_not_in_cutscene && !Global.is_on_video && !is_in_winterHorrorland_cutscene:
		sectionCamera.zoom = lerp(sectionCamera.zoom, SongData.stageZoom, 0.09);
		
	set_cool_animated_icon(animatedIconP1, true);
	set_cool_animated_icon(animatedIconP2, true);
	
	for i in [iconP1, iconP2, iconP3]:
		i.scale = lerp(i.scale, Vector2(1.0, 1.0), 0.08);
		i.rotation_degrees = lerp(i.rotation_degrees, 0.0, 0.065);
		
	if !is_on_intro && Conductor.getSongTime >= 0:
		match typeof(playlist):
			TYPE_ARRAY:
				if !playlist.is_empty():
					discord_songName = "Playing: %s (%s)"%[playlist[0], songDiff];
					
			TYPE_STRING:
				discord_songName = "Playing: %s (%s)"%[playlist, songDiff];
				
	Discord.update_discord_info("Playstate", discord_songName, "Another FNF Engine Made In Godot", dad.curIcon, Conductor.getSongTime/1000);
	
	if Conductor.getSongTime >= 0 && !is_on_intro:
		timeBar.value = Conductor.getSongTime/1000;
		
	timeBar.max_value = inst.stream.get_length();
	
	var healthRemap = remap(health, healthBar.min_value, healthBar.max_value, 850, 250);
	
	iconP1.position.x = lerp(iconP1.position.x, healthRemap+160, 0.40);
	iconP2.position.x = lerp(iconP2.position.x, healthRemap+55, 0.40);
	iconP3.position.x = lerp(iconP3.position.x, healthRemap+20, 0.40);
	
	animatedIconP1.position.x = lerp(iconP1.position.x, healthRemap+160, 0.40);
	animatedIconP2.position.x = lerp(iconP2.position.x, healthRemap+55, 0.40);
	
	if Global.is_a_bot:
		botplayText.show();
		botplayTime -= delta;
		if botplayTime <= 0:
			botplayText.modulate.a = 1 if can_show_botplay else 0;
			can_show_botplay = false if can_show_botplay else true;
			botplayTime = 0.60;
	else:
		botplayText.hide();
		
	for i in array_notes:
		var note_data = int(i[1])%(8 if !SongData.haveTwoOpponents else 12);
		var distance = (i[0] - Conductor.getSongTime)*Conductor.songSpeed;
		if distance <= 2150 && !i[7]:
			spawnNote(i[0], note_data, i[2], i[3], i[4], i[5], i[6]);
			i[7] = true;
			
	if array_events_notes != [] or array_events_notes != null:
		for i in array_events_notes:
			if Conductor.getSongTime >= i[0]:
				set_event(i[2], i[3], i[4]);
				array_events_notes.erase(i);
				
	var missed_notes = [];
	for note in notesList:
		if note == null:
			continue;
			
		var ms = (note.strumTime - Conductor.getSongTime);
		var new_noteGrp = playerStrum if note.isPlayer else opponentStrum;
		if note.secondOpponentNote:
			new_noteGrp = newOpponentStrum;
			
		var strum = new_noteGrp.get_child(note.noteData);
		
		strumX = new_noteGrp.position.x + strum.position.x;
		strumY = new_noteGrp.position.y + strum.position.y;
		
		if note.note != null:
			note.note.offset = strum.note.offset;
			
		note.position.x = (new_noteGrp.position.x + strum.position.x)+strum.note.offset.x;
		note.rotation = strum.rotation;
		note.modulate.a = strum.modulate.a;
		note.strumY = strumY;
		note.strumX = strumX;
		
		if (!note.is_pressing or note.long_missed or note.missed):
			note.position.y = strumY - (Conductor.getSongTime - note.strumTime) * (0.45 * Conductor.songSpeed) if !GlobalOptions.down_scroll else strumY + (Conductor.getSongTime - note.strumTime) * (0.45 * Conductor.songSpeed);
			
		if note.is_pressing && !note.missed && !note.long_missed:
			note.position.y = strumY+strum.note.offset.y;
			
		note.can_press = int(ms) <= 175 && int(ms) >= -140 && note.isPlayer;
		
		if Conductor.getSongTime > 155+note.strumTime && note.isPlayer && !note.is_pressing && !note.is_a_bad_note:
			note.missed = true;
			playBfMissAnim(note);
			note.miss_note();
			
		if Conductor.getSongTime > 320+note.strumTime && note.sustainLenght <= 0 && note.isPlayer:
			missed_notes.append(note);
			
		elif Conductor.getSongTime > 320+note.strumTime+note.sustainLenght && note.sustainLenght > 0 && !note.is_pressing && note.isPlayer:
			missed_notes.append(note);
			
	for missedNote in missed_notes:
		playerNotes.erase(missedNote);
		notesList.erase(missedNote);
		missedNote.queue_free();
		
	playerNotes = playerNotes.filter(func(note): return note != null);
	notesList = notesList.filter(func(note): return note != null);
	
	for note in playerNotes:
		if note == null or note.missed:
			continue;
			
		if Global.is_a_bot:
			if Conductor.getSongTime >= note.strumTime && note.can_press && playerNotes.size() > 0 && note.isPlayer && note.must_press && !note.is_a_bad_note:
				delete_note(note.custom_note_dir);
				if note.sustainLenght == 0:
					playerNotes.erase(note);
					notesList.erase(note);
				else:
					if note.is_pressing:
						if note.sustainLenght <= 0:
							note.is_pressing = false;
							playerNotes.erase(note);
							notesList.erase(note);
						else:
							note.is_pressing = true;
							note.long_note_missTimer = 0.0;
			continue;
			
		if note.can_press && playerNotes.size() > 0 && note.isPlayer && note.must_press:
			var key = "ui_" + note.custom_note_dir;
			if Input.is_action_just_pressed(key):
				playerStrum.emit_signal("canPress", int(note.noteData));
				delete_note(note.custom_note_dir);
				
			if note.sustainLenght > 0 or note.isSustain:
				if Input.is_action_pressed(key) && !note.long_press_missed && !note.missed && !note.long_note_missTimer > 0:
					if note.is_pressing:
						if note.sustainLenght <= 0:
							note.is_pressing = false;
							playerNotes.erase(note);
							notesList.erase(note);
						else:
							note.is_pressing = true;
							note.long_note_missTimer = 0.0;
							
	opponents_strums = [opponentNotes] if !SongData.haveTwoOpponents else [opponentNotes, new_opponentNotes];
	
	for strums in opponents_strums:
		for note in strums:
			if note == null or note.isPlayer or note.is_a_bad_note:
				continue;
				
			if Conductor.getSongTime >= note.strumTime && strums.size() > 0:
				playOpponentAnim(note);
				if note.sustainLenght == 0:
					note.opponent_pressed();
					strums.erase(note);
					notesList.erase(note);
				else:
					if note.note != null:
						note.note.queue_free();
						
					note.is_pressing = true;
					if note.sustainLenght <= 0:
						note.is_pressing = false;
						strums.erase(note);
						notesList.erase(note);
						
	for i in notes_to_delete:
		playerNotes.erase(i);
		notesList.erase(i);
		
	if appleCoreNotes:
		var center = Vector2(get_viewport().size.x / 4, get_viewport().size.y / 4);
		for note in playerStrum.get_children():
			note.position = (center-Vector2(220, 0)) + Vector2(sin(appleCoreStrumTime + note.noteData) * 200, cos(appleCoreStrumTime + note.noteData) * 300);
			
		for note in opponentStrum.get_children():
			note.position = center + Vector2(sin((appleCoreStrumTime - note.noteData)*2) * 200, cos((appleCoreStrumTime + note.noteData)*2) * 300);
			
	for i in [dad, gf, bf, new_opponent]:
		if i != null:
			cam_follow_poses(i);
			
	var curMinutes = str(int(inst.get_playback_position()) / 60).pad_zeros(1);
	var curSeconds = str(int(inst.get_playback_position()) % 60).pad_zeros(2);
	var maxMinutes = str(int(inst.stream.get_length()) / 60).pad_zeros(1);
	var maxSeconds = str(int(inst.stream.get_length()) % 60).pad_zeros(2);
	
	if Conductor.getSongTime >= 0:
		timeText.text = curMinutes + ":" + curSeconds + " / " + maxMinutes + ":" + maxSeconds;
		if Conductor.getSongTime/1000 >= inst.stream.get_length() && !finished_song:
			match curSong:
				"test":
					AchievementPopUp.set_achievement('debug mode', true);
					
			match rankName:
				"SFC", "GFC":
					AchievementPopUp.set_achievement('combo master', true);
					AchievementPopUp.set_achievement('perfectionist', true);
				"FC":
					AchievementPopUp.set_achievement('combo master', true);
					
			if health <= 15:
				AchievementPopUp.set_achievement('fucked up', true);
				
			if isStoryMode && playlist.size() == 1:
				set_new_achievement(Global.cur_week, true);
				
			if AchievementPopUp.achievements_fuck.size() == 0 or AchievementPopUp.achievements_fuck.is_empty():
				finishSong();
				
			finished_song = true;
	else:
		timeText.text = str("0:00") + " / " + maxMinutes + ":" + maxSeconds;
		
	if health <= 0:
		playerDead();
		
	set_icon();
	newRank();
	
func delete_note(note_direction):
	var new_strumTime = INF;
	var new_note = null;
	
	playerNotes.sort_custom(Callable(self, "sort_notes"));
	notesList.sort_custom(Callable(self, "sort_notes"));
	
	notes_to_delete = notes_to_delete.filter(func(note): return note != null);
	
	for note in playerNotes:
		if note == null:
			continue;
			
		if note.custom_note_dir == note_direction:
			var distance = (note.strumTime - Conductor.getSongTime);
			if distance <= new_strumTime && note.can_press:
				new_strumTime = distance;
				new_note = note;
				
				if !note.isSustain:
					if new_note.is_a_bad_note:
						playBfMissAnim(new_note);
						new_note.miss_note();
					else:
						playBfAnim(new_note);
						new_note.pressed();
						
					new_note.queue_free();
					note.note_pressed = true;
					notes_to_delete.append(note);
				else:
					if new_note.note != null:
						new_note.note.queue_free();
						
					new_note.is_pressing = true;
					
func set_new_achievement(achievement, final):
	AchievementPopUp.set_achievement(achievements_map[achievement][0], final);
	if songDiff == "hard":
		AchievementPopUp.set_achievement(achievements_map[achievement][1], final);
		
func play_icon_anim(icon, anim, is_animated):
	if !is_animated:
		if icon.texture.get_width() > 150:
			match anim:
				"win":
					if icon.texture.get_width() <= 300:
						icon.frame = 0;
					elif icon.texture.get_width() >= 450:
						icon.frame = 2;
				"lose":
					icon.frame = 1;
				"idle":
					icon.frame = 0;
		else:
			icon.frame = 0;
			
	else:
		var cur_anim = anim;
		if anim in ["win", "lose"] && !icon.get_child(0).end_transition:
			cur_anim = "transition";
			
		icon.get_child(0).play_icon_anim(cur_anim);
		
func set_icon():
	var iconPlayer = animatedIconP1 if bf.animatedIcon else iconP1;
	var iconOpponent = animatedIconP2 if dad.animatedIcon else iconP2;
	
	var iconP1_Anim = "idle";
	var iconP2_Anim = "idle";
	var iconP3_Anim = "idle";
	
	if health <= 15:
		iconP1_Anim = "lose";
		iconP2_Anim = "win";
		iconP3_Anim = "win";
		
	elif health >= 80:
		iconP1_Anim = "win";
		iconP2_Anim = "lose";
		iconP3_Anim = "lose";
		
	play_icon_anim(iconPlayer, iconP1_Anim, bf.animatedIcon);
	play_icon_anim(iconOpponent, iconP2_Anim, dad.animatedIcon);
	play_icon_anim(iconP3, iconP3_Anim, false);
	
func reset_status():
	totalHits = 0;
	combo = 0;
	score = 0;
	shits = 0;
	bads = 0;
	goods = 0;
	sicks = 0;
	
	Conductor.curBeat = 0;
	Conductor.curStep = 0;
	Conductor.lastStep = 0;
	Conductor.lastBeat = 0;
	
func pressedNote(note):
	if note.is_a_bad_note:
		return;
		
	voices.volume_db = 0;
	playerStrum.get_child(note.noteData).strumPressed = true;
	
	var ms = (note.strumTime - Conductor.getSongTime);
	var pressed = false;
	
	if note.sustainLenght <= 0:
		health = min(health+2.30, 100.0);
		
	if !pressed:
		for i in rating_data.keys():
			if ms <= rating_data[i]["Ms"][0] && !ms <= rating_data[i]["Ms"][1]:
				notesPlayed += rating_data[i]["Percent"];
				score += rating_data[i]["Score"];
				
				match rating_data[i]["Rating"]:
					"shits":
						shits += 1;
					"bads":
						bads += 1;
					"goods":
						goods += 1;
					"sicks":
						sicks += 1;
						
				rating_spr.pop_up_rating(rating_data[i]["RatingID"]);
				
				if i == "Sick" && GlobalOptions.show_splashes:
					var curSplash = int(randi_range(1, 2)) if !SongData.isPixelStage else 1;
					var splashData = int(note.noteData)%4;
					var splashAnim = note.noteAnim;
					var splashPosX = playerStrum.position.x+playerStrum.get_child(note.noteData).position.x;
					var splashPosY = playerStrum.position.y+playerStrum.get_child(note.noteData).position.y;
					
					splash_note(curSplash, splashData, splashAnim, splashPosX, splashPosY);
					
				break;
				
		totalHits += 1;
		combo += 1;
		
		if GlobalOptions.updated_hud != "classic hud":
			nums_spr.pop_up_rating();
			if combo >= 10:
				combo_spr.pop_up_rating();
			else:
				combo_spr.hide();
		else:
			if combo >= 10:
				nums_spr.pop_up_rating();
			else:
				nums_spr.hide();
				
		updateScoreText();
		
		pressed = true;
		
func miss_note():
	SoundStuff.playAudio("miss_sounds/missnote%s"%[int(randi_range(1, 3))], false);
	SoundStuff.audio.volume_db = -8;
	
	voices.volume_db = -80;
	misses += 1;
	health -= 4;
	notesPlayed = max(notesPlayed-0.8, 0.0);
	score -= 70;
	
	if combo > 10 && gf != null && SongData.gfPlayer != "none":
		gf._playAnim("sad");
		
	combo = 0;
	
	if curStage == "philly remix" && (curSong != "philly-nice" && songDiff == "remix"):
		stage.funny_guy();
		
	if GlobalOptions.updated_hud != "classic hud":
		rating_spr.pop_up_rating(4);
		
	updateScoreText();
	
	await get_tree().create_timer(0.3).timeout;
	voices.volume_db = 0;
	
func playBfMissAnim(curNote):
	if curNote.sustainLenght > 0 && curNote.is_pressing && curNote.is_a_bad_note:
		health = max(health-0.15, 0.0);
		
	if curNote.sustainLenght <= 0 && curNote.is_a_bad_note:
		health = max(health-4, 0.0);
		
	var coolAnims = singAnims[int(curNote.noteData)%4];
	if curNote.is_a_bad_note:
		if bf.animList.has("hit"):
			bf._playAnim("hit");
		else:
			bf.modulate = Color(0x5425dfff);
			bf._playAnim(coolAnims);
			
		bf.loop_anim(curNote.isSustain);
	else:
		if bf.animList.has(coolAnims+" MISS"):
			bf._playAnim(coolAnims+" MISS");
		else:
			bf.modulate = Color(0x5425dfff);
			bf._playAnim(coolAnims);
			
func playBfAnim(curNote):
	if curNote.sustainLenght > 0 && curNote.is_pressing:
		health = min(health+0.17, 100.0);
		
	bf.modulate = Color.WHITE;
	if curNote.no_anim:
		return;
		
	var coolAnims = singAnims[int(curNote.noteData)%4];
	var altAnim = "-alt" if curNote.is_altAnim && bf.animList.has(coolAnims+"-alt") else "";
	
	if curNote.isGfNote && gf != null:
		gf._playAnim(coolAnims, curNote.isSustain);
		return;
		
	if curNote.is_hey_note:
		bf._playAnim("hey");
		return;
		
	if !bf.is_player or bf.curCharacter == "tankman":
		match singAnims[int(curNote.noteData)%4]:
			"singLeft":
				coolAnims = "singRight";
			"singRight":
				coolAnims = "singLeft";
				
	if !curNote.isGfNote && !curNote.is_hey_note && !curNote.is_a_bad_note:
		bf._playAnim(coolAnims+altAnim, curNote.isSustain);
		
func playOpponentAnim(curNote):
	if curNote.no_anim:
		return;
		
	var coolAnims = singAnims[int(curNote.noteData)%4];
	var altAnim = "-alt" if curNote.is_altAnim && dad.animList.has(coolAnims+"-alt") else "";
	
	if curNote.isGfNote && gf != null:
		gf._playAnim(coolAnims, curNote.isSustain);
		return;
		
	if curNote.is_hey_note:
		dad._playAnim("hey");
		return;
		
	if dad.is_player && dad.curCharacter != "tankman" && dad.curCharacter != "pico":
		match singAnims[int(curNote.noteData)%4]:
			"singLeft":
				coolAnims = "singRight";
			"singRight":
				coolAnims = "singLeft";
				
	if !curNote.isGfNote && !curNote.is_hey_note && !curNote.secondOpponentNote:
		dad._playAnim(coolAnims+altAnim, curNote.isSustain);
		
	if curNote.secondOpponentNote:
		var secondAltAnim = "-alt" if curNote.is_altAnim && new_opponent.animList.has(coolAnims+"-alt") else "";
		new_opponent._playAnim(coolAnims+secondAltAnim, curNote.isSustain);
		
func play_strum_anim(note = null, is_opponent = false, timer = 0.0, is_second_opponent = false, isCPU = false):
	var taget_key = "player";
	var target = {
		"player": playerStrum,
		"opponent": opponentStrum,
		"second opponent": newOpponentStrum
	};
	
	if is_second_opponent && !is_opponent:
		taget_key = "second opponent";
		
	elif is_opponent:
		taget_key = "opponent";
		
	var strum_target = target[taget_key];
	if isCPU:
		strum_target.get_child(note.noteData).reset_arrow_anim = timer;
		
	strum_target.get_child(note.noteData).play_note_anim("confirm");
	
func move_cam(smoothing, pos):
	if !smoothing:
		sectionCamera.global_position = pos;
	else:
		sectionCamera.global_position = lerp(sectionCamera.global_position, pos, 0.55);
		
var camOffset = Vector2.ZERO;
func cam_follow_poses(char):
	if char.cam_follow_pos:
		match char.curAnim:
			"singLeft":
				camOffset = Vector2.LEFT*20;
			"singDown":
				camOffset = Vector2.DOWN*20;
			"singUp":
				camOffset = Vector2.UP*20;
			"singRight":
				camOffset = Vector2.RIGHT*20;
			"idle dance":
				camOffset = Vector2.ZERO;
				
		sectionCamera.offset = lerp(sectionCamera.offset, camOffset, 0.07);
		
func playerDead():
	print("player is dead");
	Global.death_count += 1;
	
	if bf.have_death_animation == true:
		Global.is_on_death_screen = true;
		can_pause = false;
		Global.changeScene("/gameplay/death_scene/death_scene", false, false);
	else:
		Global.reloadScene(true, false);
		
func newRank():
	if misses >= 10:
		return "Clear";
	elif misses > 0:
		return "SDCB";
	elif bads > 0 or shits > 0:
		return "FC";
	elif goods > 0:
		return "GFC";
	elif sicks > 0:
		return "SFC";
	else:
		return "???";
		
func setRank(old_rank, new_rank):
	var rank_map = {"SFC": 5, "GFC": 4, "FC": 3, "SDCB": 2, "Clear": 1, "???": 0, "": 0};
	return rank_map[old_rank] < rank_map[new_rank];
	
func newPercent():
	if totalHits <= 0:
		return "???";
		
	percent = min(float(notesPlayed/totalHits), 1.0);
	
	var percents = percentData.keys();
	percents.sort_custom(func(a, b): return percentData[a][1] < percentData[b][1]);
	
	for i in percents:
		if float(percent) <= float(percentData[i][1]):
			return percentData[i][0];
			
		if float(percent) >= 1.0:
			return "Perfect!!!";
			
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && !ev.echo:
			if ev.keycode in [KEY_R] && !GlobalOptions.no_R:
				playerDead();
				
			if ev.keycode in [Global.get_key("7")] && can_pause:
				Global.songsShit = playlist if !Global.isStoryMode else playlist[0];
				Global.is_playing = false;
				Global.changeScene("menus/editors/chart_editor/chartState", true, false);
				
			if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && can_pause && !TennaJumpscare.itsTvTime:
				pause_menu.can_use = true;
				pause_menu.visible = true;
				
				pause_menu._paused();
				get_tree().paused = true;
				
				Discord.update_discord_info("pause", "Paused");
				
			if ev.keycode in [KEY_F1]:
				finishSong();
				
func startCoutdown():
	is_in_winterHorrorland_cutscene = false;
	MusicManager._stop_music();
	is_on_intro = true;
	start_song = true;
	
	var countdownPath = "default" if !SongData.isPixelStage else "pixel";
	var idle_loop = 0;
	
	if skipIntro && is_on_intro:
		can_pause = true;
		is_on_intro = false;
		Conductor.getSongTime = 0.0;
		
		if SongData.needVoice:
			voices.play(0.0);
		inst.play(0.0);
		
		return;
		
	for i in 5:
		await get_tree().create_timer(Conductor.crochet/1000).timeout;
		idle_loop += 1;
		
		everyone_dance(bf, SongData.player1, idle_loop);
		everyone_dance(dad, SongData.player2, idle_loop);
		everyone_dance(gf, SongData.gfPlayer, idle_loop);
		
		if SongData.haveTwoOpponents:
			everyone_dance(new_opponent, SongData.player3, idle_loop);
			
		if countdownSprite != null:
			match i:
				0:
					if GlobalOptions.updated_hud != "classic hud":
						set_contdownSpr(countdownPath, countdownset[countdownPath][0] + ratingPart);
					SoundStuff.playAudio("intro3", SongData.isPixelStage);
				1:
					set_contdownSpr(countdownPath, countdownset[countdownPath][1] + ratingPart);
					SoundStuff.playAudio("intro2", SongData.isPixelStage);
				2:
					set_contdownSpr(countdownPath, countdownset[countdownPath][2] + ratingPart);
					SoundStuff.playAudio("intro1", SongData.isPixelStage);
				3:
					set_contdownSpr(countdownPath, countdownset[countdownPath][3] + ratingPart);
					SoundStuff.playAudio("introGo", SongData.isPixelStage);
				4:
					countdownSprite.hide();
					can_pause = true;
					is_on_intro = false;
					
					if SongData.needVoice:
						voices.play(0.0);
					inst.play(0.0);
					
func set_contdownSpr(path, spr):
	var tween = get_tree().create_tween();
	tween.tween_property(countdownSprite, "modulate:a", 1.0, 0.14);
	countdownSprite.texture = load("res://assets/images/coutdown/%s/%s.png"%[path, spr]);
	tween.tween_property(countdownSprite, "modulate:a", 0.0, 0.14);
	
func startSong():
	if SongData.song != "":
		var music_inst = load("res://assets/songs/" + SongData.song + "/Inst.ogg");
		var music_voices = load("res://assets/songs/" + SongData.song + "/Voices.ogg");
		
		inst.stream = music_inst;
		voices.stream = music_voices;
		
func finishSong():
	Global.restartSong = false;
	Global.death_count = 0;
	
	var songSet = playlist if !Global.isStoryMode else playlist[0];
	var diffSet = "" if songDiff == "normal" else str('-', songDiff);
	var song_percent = snapped(float(notesPlayed/totalHits)*100, 0.01) if totalHits > 0 else 0.0;
	
	if score > HighScore.get_score(songSet, diffSet):
		HighScore.get_song_score(songSet, diffSet, score);
		
	if setRank(HighScore.get_rank(songSet, diffSet), rankName):
		HighScore.get_song_rank(songSet, diffSet, rankName);
		
	if song_percent > HighScore.get_percent(songSet, diffSet):
		HighScore.get_song_percent(songSet, diffSet, song_percent);
		
	inst.stop();
	voices.stop();
	can_pause = false;
	
	match curSong:
		"test":
			HighScore.unlocksong("test", "bf-pixel", [0.0, 0.845, 1.0], ["easy", "normal", "hard"]);
		#"south-old":
		#	HighScore.unlocksong("south-old", "skidPump", [0.792, 0.505, 0.24], ["old"]);
		"monster":
			HighScore.unlocksong("monster", "monster", [1, 0.989, 0], ["easy", "normal", "hard"]);
			
	if Global.is_on_chartMode:
		Global.is_on_chartMode = false;
		
	if Global.isStoryMode:
		playlist.remove_at(0);
		print(playlist);
		
		if curSong == "eggnog" && !is_on_intro:
			Flash.just_appear(10, Color(0.0, 0.0, 0.0));
			SoundStuff.playAudio("Lights_Shut_off", false);
			
		if playlist.size() == 0 or playlist.is_empty():
			HighScore.week_status[Global.cur_week] = true;
			HighScore.save_week_status();
			
			await get_tree().create_timer(0.1).timeout
			
			MusicManager._play_music("freakyMenu", true, true);
			Global.changeScene("menus/story_mode/storyMode", true, false);
			Global.is_playing = false;
			
		elif playlist.size() > 0:
			await get_tree().create_timer(0.1 if curSong != "eggnog" else 1.5).timeout
			
			Global.reloadScene();
			SongData.loadJson(playlist[0], "" if songDiff == "normal" else songDiff);
	else:
		await get_tree().create_timer(0.1).timeout
		
		MusicManager._play_music("freakyMenu", true, true);
		Global.changeScene("menus/freeplay/freeplay_menu", true, false);
		Global.is_playing = false;
		
	if Global.is_on_chartMode && curSong != "test" && !curSong == "south-old" && curSong != "monster":
		Global.changeScene("menus/editors/chart_editor/chartState", true, false);
		
func splash_note(data, noteData, dir, strumX, strumY):
	var splash = splash_pixel.instantiate() if SongData.isPixelStage else splash_normal.instantiate();
	splash.cool_splash(data, noteData, dir, strumX, strumY);
	note_splshes.add_child(splash);
	
func updateScoreText():
	ratingName = newPercent();
	rankName = newRank();
	
	if GlobalOptions.updated_hud == "new hud":
		if totalHits <= 0:
			scoreText.text = 'Score: %s / Misses: %s / Rating: %s / Rank: %s'%[score, misses, ratingName, rankName];
			scoreText.position.x = 350;
		else:
			scoreText.text = 'Score: %s / Misses: %s / Rating: %s (%s) / Rank: %s'%[score, misses, ratingName, str(snapped(float(notesPlayed/totalHits)*100, 0.01), "%"), rankName];
			scoreText.position.x = 260;
	else:
		scoreText.text = 'Score: %s'%[score];
		
	if GlobalOptions.show_ratingLabel:
		if GlobalOptions.updated_hud == "classic hud":
			ratingText.text = "Total Hits: %s\nSicks: %s\nGoods: %s\nBads: %s\nShits: %s\nMisses: %s\nRank: %s"%[int(totalHits), int(sicks), int(goods), int(bads), int(shits), int(misses), rankName];
		else:
			ratingText.text = "Total Hits: %s\nSicks: %s\nGoods: %s\nBads: %s\nShits: %s"%[int(totalHits), int(sicks), int(goods), int(bads), int(shits)];
			
var cam_target = null;
func step_hit(step):
	var curSection = floor(step/16);
	
	if curSection < SongData.songNotes.size():
		if SongData.chartData["song"]["notes"][curSection]["changeBPM"]:
			Conductor.changeBpm(SongData.chartData["song"]["notes"][curSection]["bpm"]);
			
		camera_on_Bf = SongData.chartData["song"]["notes"][curSection]["mustHitSection"];
		gf_is_singing = SongData.chartData["song"]["notes"][curSection]["gfSection"];
		
	if !camera_focus:
		cam_target = dad;
		if gf_is_singing:
			cam_target = gf;
			
		elif camera_on_Bf:
			cam_target = bf;
			
		if sectionCamera != null && Global.is_playing:
			move_cam(true if GlobalOptions.updated_cam == "smooth" else false, (cam_target.global_position + Vector2(cam_target.camera_pos[0], cam_target.camera_pos[1])));
			
func beat_hit(beat):
	if GlobalOptions.show_songCard && Global.is_playing:
		match beat:
			1:
				var tw = get_tree().create_tween();
				tw.tween_property(song_card, "position:x", 280, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
			9:
				var tw = get_tree().create_tween();
				tw.tween_property(song_card, "position:x", -1200, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN);
				tw.tween_callback(song_card.queue_free);
				
	everyone_dance(bf, SongData.player1, beat);
	everyone_dance(dad, SongData.player2, beat);
	everyone_dance(gf, SongData.gfPlayer, beat);
	
	if SongData.haveTwoOpponents:
		everyone_dance(new_opponent, SongData.player3, beat);
		
	if GlobalOptions.screen_zoom:
		if beat % 4 == 0 && !is_on_intro:
			sectionCamera.zoom = SongData.stageZoomBeat;
			
	set_cool_animated_icon(animatedIconP1, false);
	set_cool_animated_icon(animatedIconP2, false);
	
	if GlobalOptions.updated_icon == "disabled":
		return;
		
	match GlobalOptions.updated_icon:
		"default":
			for i in [iconP1, iconP2, iconP3]:
				i.scale = Vector2(1.25, 1.25); #Vector2((i.texture.get_width() + (90 * i.scale.x * 1.5)) / i.texture.get_width(), (i.texture.get_height() + (90 * i.scale.y * 0.5)) / i.texture.get_height());
				
		"new bouncy":
			if beat % 2 == 0:
				icon_bouncy(iconP1, Vector2(1.1, 0.4), 10);
				icon_bouncy(iconP2, Vector2(1.2, 0.5), -10);
				icon_bouncy(iconP3, Vector2(1.2, 0.5), -10);
			else:
				icon_bouncy(iconP1, Vector2(1.2, 0.5), -10);
				icon_bouncy(iconP2, Vector2(1.1, 0.4), 10);
				icon_bouncy(iconP3, Vector2(1.1, 0.4), 10);
				
		"golden apple":
			if beat % 2 == 0:
				icon_bouncy(iconP1, Vector2(1.1, 0.8), 15);
				icon_bouncy(iconP2, Vector2(1.1, 1.3), -15);
				icon_bouncy(iconP3, Vector2(1.1, 1.3), -15);
			else:
				icon_bouncy(iconP1, Vector2(1.1, 1.3), -15);
				icon_bouncy(iconP2, Vector2(1.1, 0.8), 15);
				icon_bouncy(iconP3, Vector2(1.1, 0.8), 15);
				
func icon_bouncy(icon, scale, rotate):
	icon.scale = scale;
	icon.rotation_degrees = rotate;
	
func everyone_dance(char, check_char, beat):
	if check_char != "none":
		if (beat % 2 == 0 if char.anim_beat == 2 else beat % int(char.anim_beat) == 0) && !char.curAnim.begins_with("sing"):
			char.dance();
			
func changeCharacter(id, char):
	var charPosition = Vector2.ZERO;
	match id:
		"0", "bf":
			remove_character(bf);
			charPosition = SongData.gfStagePosition if char == "gf" else SongData.player1;
			
			bf = add_character(bf, charPosition, SongData.player1Zindex, char, 4);
			bf.character.flip_h = true if !bf.is_player else false;
			healthBar.tint_progress = Color("#ff000f") if GlobalOptions.updated_hud == "classic hud" else bf.healthBar_Color;
			iconP1.texture = load("res://assets/images/icons/icon-%s.png"%[bf.curIcon]);
			set_icon_hframes(iconP1);
			
		"1", "dad":
			remove_character(dad);
			charPosition = SongData.gfStagePosition if SongData.player2 == "gf" else SongData.player2StagePosition;
			
			dad = add_character(dad, charPosition, SongData.player2Zindex, char, 3);
			dad.character.flip_h = true if dad.is_player else false;
			healthBar.tint_under = Color("#ff000f") if GlobalOptions.updated_hud == "classic hud" else dad.healthBar_Color;
			iconP2.texture = load("res://assets/images/icons/icon-%s.png"%[dad.curIcon]);
			set_icon_hframes(iconP2);
			
		"2", "gf":
			remove_character(gf);
			charPosition = SongData.gfStagePosition;
			
			gf = add_character(gf, charPosition, SongData.gfZindex, char, 1);
			
func changeBg(newBg):
	for i in stageGrp.get_children():
		stageGrp.remove_child(i);
		i.queue_free();
		
	stage = load("res://source/stages/" + newBg + ".tscn").instantiate();
	stageGrp.add_child(stage);
	
	curStage = newBg.to_lower();
	
func characterPlayAnim(id, anim):
	match id:
		"0", "bf":
			bf._playAnim(anim);
			
		"1", "dad":
			dad._playAnim(anim);
			
		"2", "gf":
			if SongData.gfPlayer != "" && gf != null:
				gf._playAnim(anim);
				
func set_new_camPos(pos, just_for_one_section):
	var splitedPos = pos.split(",");
	var new_cam_pos = Vector2(splitedPos[0].to_int(), splitedPos[1].to_int());
	
	if sectionCamera != null && Global.is_playing:
		move_cam(true if GlobalOptions.updated_cam == "smooth" else false, new_cam_pos);
		
	camera_focus = (just_for_one_section == "true");
	
func set_icon_hframes(icon):
	if icon.texture.get_width() <= 300:
		icon.hframes = 2;
	if icon.texture.get_width() >= 450:
		icon.hframes = 3;
	if icon.texture.get_width() <= 150:
		icon.hframes = 1;

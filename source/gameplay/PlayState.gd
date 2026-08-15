extends Node2D

@onready var hud = $hud/Hud_Layer;
@onready var timeText = $'hud/Hud_Layer/timeLabel';
@onready var ratingText = $'hud/Hud_Layer/ratingLabel'
@onready var scoreText = $'hud/Hud_Layer/scoreLabel';
@onready var timeBar = $"hud/Hud_Layer/timeBar";
@onready var countdownSprite = $'hud/Hud_Layer/countdown';

@onready var healthBar = $'hud/Hud_Layer/healthBar';

@onready var voices = $voices;
@onready var inst = $inst;

var songLength = 0.0;

var iconP1 = Icon.new();
var iconP2 = Icon.new();
@onready var iconGrp = $'hud/Hud_Layer/icons';

var ratingPart = "";
var ratings = ["sick", "good", "bad", "shit", "miss"];

@onready var msText = $rating/Rating_Layer/ms_text;

@onready var rating_spr = $'rating/Rating_Layer/rating';
@onready var combo_spr = $'rating/Rating_Layer/combo';
@onready var nums_spr = $'rating/Rating_Layer/nums';

@onready var pause_menu = $'pause/Pause_Layer';
@onready var dialogue_box = $'dialogue/DialogueBox';

@onready var playerStrum = $'strums/Strum_Layer/Player Notes';
@onready var opponentStrum = $'strums/Strum_Layer/Opponent Notes';
@onready var game_strums = $'strums/Strum_Layer';
@onready var note_splshes = $'strums/Strum_Layer/Splashes';

var can_pause = false;

var health = 50.0;

var sicks = 0;
var goods = 0;
var bads = 0;
var shits = 0;

var combo = 0;
var score = 0;
var misses = 0;
var ratingName = '';
var rankName = '';
var accuracyPercent = 0.0;

var totalHits = 0;
var notesPlayed = 0;
var percent = 0;

var isDead = false;

var bf = Character.new();
var gf = Character.new();
var dad = Character.new();

@onready var stageGrp = $'stage';
var stage = null;

var is_on_intro = false;
var finished_song = false;

var skipIntro = false;

var curStage = "";
var curSong = "";

var playlist = [];
var songDiff = [];

@onready var sectionCamera = $"Camera2D";

var camera_position = Vector2();
var camera_focus = false;
var camera_on_Bf = false;
var gf_is_singing = false;

@onready var botplayText = $'hud/Hud_Layer/botplayLabel';
var botplayTime = 0;

var countdownset = {};
var percentData = {};
var rating_data = {};
var rank_map = {};
var achievements_map = {};

@onready var eventLoader = $EventLoader;

func _ready():
	Conductor.reset();
	
	var gameplay_data = Global.load_json("assets/data/gameplay_data");
	achievements_map = gameplay_data["achievements_map"];
	rank_map = gameplay_data["rank_map"];
	percentData = gameplay_data["percentData"];
	countdownset = gameplay_data["countdownset"];
	rating_data = gameplay_data["rating_data"];
	
	get_tree().paused = false;
	pause_menu.visible = false;
	pause_menu.can_use = false;
	
	playlist = SongData.week_songs;
	songDiff = SongData.week_diffs;
	
	for i in [rating_spr, combo_spr, nums_spr]:
		if GlobalOptions.rating_mode == "hud element":
			i.reparent($rating/Rating_Layer, true);
			
		elif GlobalOptions.rating_mode == "game element":
			i.reparent($hud, true);
			
	SongData.isOnDeathScreen = false;
	SongData.isPlaying = true;
	
	GlobalOptions.connect("ghost_tapping_miss", miss_note);
	
	Achievements.connect("end_achievement", finishSong);
	
	Conductor.connect("new_step", step_hit);
	Conductor.connect("new_beat", beat_hit);
	
	Global.connect("end_dialogue", startCountdown);
	Global.connect("end_cutscene", startCountdown);
	
	eventLoader.connect("event_emit", eventEmit);
	
	stage = load("res://source/stages/%s/%s.tscn"%[SongData.stage, SongData.stage]).instantiate();
	if stage is Stage:
		stage.init_game(self);
		
	SongData.loadStageJson(SongData.stage);
	
	curSong = SongData.song;
	curStage = SongData.stage;
	
	ScriptLoader.init_script(self, curSong, "remix" if songDiff == "remix" else "");
	ScriptLoader.call_func("on_ready");
	
	bf = bf.init_character(self, SongData.player1StagePosition, SongData.player1Zindex, SongData.player1, 4);
	dad = dad.init_character(self, SongData.gfStagePosition if SongData.player2 == "gf" else SongData.player2StagePosition, SongData.player2Zindex, SongData.player2, 3);
	gf = gf.init_character(self, SongData.gfStagePosition, SongData.gfZindex, SongData.gfPlayer, 1);
	
	stageGrp.add_child(stage);
	
	if bf.character != null:
		bf.character.flip_h = !bf.is_player;
	if dad.character != null:
		dad.character.flip_h = dad.is_player;
		
	if dad.is_player:
		for i in dad.camera_pos.size()-1:
			dad.camera_pos[i] *= -1;
			
	if !bf.is_player:
		for i in bf.camera_pos.size()-1:
			bf.camera_pos[i] *= -1;
			
	if SongData.isPixelStage:
		countdownSprite.scale = Vector2(8,8);
		for i in [countdownSprite, rating_spr, combo_spr, nums_spr]:
			i.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST;
			
		ratingPart = '-pixel';
		
	healthBar.tint_under = Color("#ff000f") if GlobalOptions.updated_hud == "classic hud" else dad.healthBar_Color;
	healthBar.tint_progress = Color("#00ff06") if GlobalOptions.updated_hud == "classic hud" else bf.healthBar_Color;
	
	iconP1 = iconP1.init_icon(iconGrp, bf.curIcon, false, bf.animatedIcon, Vector2(710, 645));
	iconP2 = iconP2.init_icon(iconGrp, dad.curIcon, true, dad.animatedIcon, Vector2(610, 645));
	
	SongData.updated_chart = SongData.chartData;
	
	Conductor.mapBPMChanges();
	Conductor.changeBpm(SongData.songBpm);
	
	Conductor.getSongTime = -Conductor.crochet*5;
	Conductor.songSpeed = SongData.songSpeed;
	
	startSong();
	setup_hud();
	setup_hud_scroll();
	setup_classic_hud();
	updateScoreText();
	
	if SongData.isStoryMode && SongData.death_count <= 0 && !SongData.restartSong && !curSong.contains("-remix"):
		match curSong:
			"ugh": stage.ugh_intro();
			"guns": stage.guns_intro();
			"stress": stage.stress_intro();
			"thorns": stage.start_cutscene();
			
	if curSong == "ugh" or curSong == "guns" or curSong == "stress":
		stage.connect("end_tankman_cutscene", startCountdown);
		
	if Global.has_dialogue():
		SongData.is_not_in_cutscene = false;
		
		if SongData.death_count <= 0 && SongData.isStoryMode && !SongData.restartSong:
			match curSong:
				"thorns":
					stage.connect("end_senpai_cutscene", start_dialogue);
				_:
					start_dialogue();
		else:
			startCountdown();
	else:
		SongData.is_not_in_cutscene = true;
		
	if SongData.is_not_in_cutscene && !Global.is_on_video:
		startCountdown();
		
	if GlobalOptions.show_songCard:
		var newSongCard = SongCard.new();
		newSongCard.create_songBar(curSong);
		hud.add_child(newSongCard);
		hud.move_child(newSongCard, 8);
		
func start_dialogue():
	SongData.is_not_in_cutscene = false;
	dialogue_box.start();
	dialogue_box.show();
	dialogue_box.pause_song();
	
var start_song = false;
var discord_songName = "";
var last_song_seek = 0.0;

var curHealth = 0.0;
func _process(delta: float) -> void:
	ScriptLoader.call_func("on_process", [delta]);
	
	msText.modulate.a = max(msText.modulate.a - 2.0 * delta, 0.0);
	
	curHealth = lerp(curHealth, float(health), 1.0 - exp(-15.0 * delta));
	healthBar.value = curHealth;
	
	var healthPosition = remap(curHealth, healthBar.min_value, healthBar.max_value, healthBar.global_position.x + healthBar.size.x, healthBar.global_position.x);
	
	var p1Offset = iconP1.get_rect().size.x * 0.5 - 20;
	var p2Offset = iconP2.get_rect().size.x * 0.5 - 20;
	
	iconP1.position.x = lerp(iconP1.position.x, healthPosition+p1Offset, 1.0 - exp(-20.0 * delta));
	iconP2.position.x = lerp(iconP2.position.x, healthPosition-p2Offset, 1.0 - exp(-20.0 * delta));
	
	if !start_song:
		return;
		
	inst.stream_paused = pause_menu.paused;
	voices.stream_paused = pause_menu.paused;
	
	if !pause_menu.paused:
		Conductor.getSongTime += (delta*1000);
		
		if !finished_song:
			if abs(inst.get_playback_position() - Conductor.getSongTime / 1000) > 0.03 && Time.get_ticks_msec() - last_song_seek > 500:
				inst.seek(Conductor.getSongTime / 1000);
				voices.seek(Conductor.getSongTime / 1000);
				last_song_seek = Time.get_ticks_msec();
				
	if !is_on_intro && Conductor.getSongTime >= 0 && !playlist.is_empty():
		discord_songName = "Playing: %s (%s)"%[playlist[0], songDiff];
		
	if !Conductor.getSongTime < 0 && !is_on_intro:
		timeBar.value = Conductor.getSongTime/1000;
		
	botplayText.visible = GlobalOptions.isUsingBot;
	
	if GlobalOptions.isUsingBot:
		botplayTime += delta;
		botplayText.modulate.a = ((1+sin(botplayTime*5))/2) if !SongData.isPixelStage else (round((1+sin(botplayTime*5))/2));
		
	var currentPosition = max(Conductor.getSongTime / 1000.0, 0.0)
	
	var curMinutes = str(int(currentPosition) / 60).pad_zeros(1);
	var curSeconds = str(int(currentPosition) % 60).pad_zeros(2);
	var maxMinutes = str(int(songLength) / 60).pad_zeros(1);
	var maxSeconds = str(int(songLength) % 60).pad_zeros(2);
	
	var current_time = (curMinutes + ":" + curSeconds if Conductor.getSongTime >= 0 else "0:00");
	
	match GlobalOptions.timeBar_mode:
		"default":
			timeText.text = current_time + " / " + maxMinutes + ":" + maxSeconds;
		"time elapsed":
			timeText.text = current_time;
		"time left":
			var timeLeft = max(0, songLength - currentPosition);
			timeText.text = str(int(timeLeft) / 60).pad_zeros(1) + ":" + str(int(timeLeft) % 60).pad_zeros(2);
			
	if floor(Conductor.getSongTime/1000) >= songLength && !finished_song:
		if curSong == "test":
			AchievementPopUp.set_achievement('debug mode', true);
			
		match rankName:
			"SFC", "GFC":
				AchievementPopUp.set_achievement('perfectionist', true);
			"FC":
				AchievementPopUp.set_achievement('combo master', true);
				
		if health <= 15:
			AchievementPopUp.set_achievement('fucked up', true);
			
		if SongData.isStoryMode && playlist.size() == 1:
			AchievementPopUp.set_achievement(achievements_map[SongData.weekName][0 if songDiff != "hard" else 1], true);
			
		if AchievementPopUp.achievements_fuck.is_empty():
			finishSong();
			
		finished_song = true;
		
	checkPlayerDead();
	set_icon_anim();
	newRank();
	
	Discord.update_discord_info("Playstate", str(discord_songName, " ",  timeText.text), "Another FNF Engine Made In Godot", Conductor.getSongTime/1000);
	
func set_icon_anim():
	var iconP1_Anim = "idle";
	var iconP2_Anim = "idle";
	
	if health <= 15:
		iconP1_Anim = "lose";
		iconP2_Anim = "win";
		
	elif health >= 80:
		iconP1_Anim = "win";
		iconP2_Anim = "lose";
		
	iconP1.play_icon_anim(iconP1_Anim);
	iconP2.play_icon_anim(iconP2_Anim);
	
var ratingColors = {
	"sicks": Color.CYAN,
	"goods": Color.FOREST_GREEN,
	"bads": Color.DARK_RED,
	"shits": Color.DARK_RED
};
func pressedNote(note):
	if note.isSustain && GlobalOptions.show_splashes:
		var splash = splash_note(playerStrum.strumNode.get_child(note.noteData), "holdCover%s"%[note.noteAnim] if !SongData.isPixelStage else "holdpixelCover");
		note.holdSplash = splash;
		
	ScriptLoader.call_func("on_note_hit", [note]);
	bf.characterScript.call_func("on_note_hit", [note]);
	
	if note.is_a_bad_note:
		return;
		
	voices.volume_db = 0;
	
	var ms = (note.strumTime - Conductor.getSongTime);
	var strum = playerStrum.strumNode.get_child(note.noteData);
	strum.strumPressed = true;
	
	if GlobalOptions.isUsingBot:
		return;
		
	msText.modulate.a = 1.0;
	msText.text = str(snapped(ms, 0.01), "Ms");
	msText.position.x = rating_spr.position.x - msText.size.x*0.5;
	msText.position.y = rating_spr.position.y + (msText.size.x*0.5)+20;
	
	for i in rating_data.keys():
		if ms <= rating_data[i]["Ms"][0] && ms >= rating_data[i]["Ms"][1]:
			notesPlayed += rating_data[i]["Percent"];
			score += rating_data[i]["Score"]+randi_range(0, 15);
			
			msText.modulate = ratingColors[rating_data[i]["Rating"]];
			match rating_data[i]["Rating"]:
				"sicks": sicks += 1;
				"goods": goods += 1;
				"bads": bads += 1;
				"shits": shits += 1;
				
			rating_spr.pop_up_rating(rating_data[i]["RatingID"]);
			
			if i == "Sick" && GlobalOptions.show_splashes:
				splash_note(strum, ("note impact %s %s"%[randi_range(1, 2), note.noteAnim]) if !SongData.isPixelStage else "pixelsplashes%s %s"%[randi_range(1, 2), note.noteAnim]);
				
			totalHits += 1;
			combo += 1;
			break;
			
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
	
func opponentNotePressed(note):
	if note.isSustain && GlobalOptions.show_splashes:
		var splash = splash_note(opponentStrum.strumNode.get_child(note.noteData), "holdCover%s"%[note.noteAnim] if !SongData.isPixelStage else "holdpixelCover");
		note.holdSplash = splash;
		
	ScriptLoader.call_func("on_opponent_hit", [note]);
	dad.characterScript.call_func("on_note_hit", [note]);
	
func miss_note(note):
	ScriptLoader.call_func("on_note_miss", [note]);
	bf.characterScript.call_func("on_miss", [note]);
	
	if GlobalOptions.playMissSound:
		Sound.playAudio("miss_sounds/missnote%s"%[randi_range(1, 3)], false);
		Sound.audio.volume_db = -8;
		
	voices.stream.set_sync_stream_volume(0, -80.0);
	
	misses += 1;
	health -= 4;
	notesPlayed = max(notesPlayed-0.8, 0.0);
	score -= randi_range(50, 80);
	
	if combo > 10 && gf != null && SongData.gfPlayer != "none":
		gf._playAnim("sad");
		
	combo = 0;
	
	if GlobalOptions.updated_hud != "classic hud":
		rating_spr.pop_up_rating(4);
		
	updateScoreText();
	
	await get_tree().create_timer(0.3).timeout;
	voices.stream.set_sync_stream_volume(0, 0.0);
	
func noteCreated(note):
	ScriptLoader.call_func("on_note_created", [note]);
	
func eventEmit(eventName, args):
	ScriptLoader.call_func("on_event", [eventName, args]);
	
func playBfMissAnim(curNote:Note):
	if curNote.is_a_bad_note:
		if bf.animList.has("hit"):
			bf._playAnim("hit");
	else:
		var miss_anim = curNote.curNoteAnim+" MISS";
		if bf.animList.has(miss_anim):
			bf._playAnim(miss_anim);
			
func playCharacterAnim(curNote:Note, new_char):
	if curNote.no_anim:
		return;
		
	var noteAnim = curNote.curNoteAnim;
	var altAnim = "-alt" if (curNote.is_altAnim or SongData.songSections[Conductor.curSection]["altAnim"]) && new_char.animList.has(noteAnim + "-alt") else "";
	
	if curNote.note_pressed:
		return;
		
	if (curNote.isGfNote or SongData.songSections[Conductor.curSection]["gfSection"]) && gf != null:
		gf._playAnim(noteAnim);
		return;
		
	if curNote.is_hey_note:
		new_char._playAnim("hey");
		return;
		
	if !curNote.isGfNote && !curNote.is_hey_note:
		new_char._playAnim(noteAnim+altAnim);
		
	curNote.note_pressed = true;
	
func play_strum_anim(note = null, is_opponent = false, timer = 0.0, isCPU = false):
	var taget_key = "player";
	var target = {
		"player": playerStrum,
		"opponent": opponentStrum
	};
	
	if is_opponent:
		taget_key = "opponent";
		
	var strum_target = target[taget_key];
	if isCPU:
		strum_target.strumNode.get_child(note.noteData).reset_arrow_anim = timer;
		
	strum_target.strumNode.get_child(note.noteData).play_note_anim("confirm");
	
func checkPlayerDead():
	if health > 0:
		return;
		
	can_pause = false;
	
	ScriptLoader.call_func("on_death_scene");
	
	SongData.characters = {"bf": [bf.global_position, bf.scale, bf.rotation, bf.death_scene, bf.have_death_animation]};
	SongData.camera_data = {
		"position": sectionCamera.global_position,
		"zoom": sectionCamera.zoom,
		"rotation": sectionCamera.rotation
	};
	SongData.death_count += 1;
	SongData.isOnDeathScreen = true;
	Global.changeScene("/gameplay/death_scene/death_scene", false, false);
	
var RANKS = [
	{"Rank Condition": func(): return sicks > 0, "RANK": "SFC"},
	{"Rank Condition": func(): return goods > 0, "RANK": "GFC"},
	{"Rank Condition": func(): return bads > 0 or shits > 0, "RANK": "FC"},
	{"Rank Condition": func(): return misses > 0, "RANK": "SDCB"},
	{"Rank Condition": func(): return misses >= 10, "RANK": "Clear"},
]
func newRank():
	for i in RANKS:
		if i["Rank Condition"].call():
			return i["RANK"];
			
	return "???";
	
func setRank(old_rank, new_rank):
	return rank_map[old_rank] < rank_map[new_rank];
	
func setPercent():
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
	if !(ev is InputEventKey):
		return;
		
	if !ev.pressed or ev.echo:
		return;
		
	if ev.keycode == KEY_R && GlobalOptions.restart_action:
		health = 0;
		return;
		
	if ev.keycode == GlobalOptions.get_key("chartKey"):
		SongData.week_songs = playlist[0];
		SongData.isPlaying = false;
		Global.changeScene("menus/editors/chart_editor/chartState", true, false);
		
		return;
		
	elif ev.keycode == GlobalOptions.get_key("offsetKey"):
		SongData.characters = {"opponent": dad.curCharacter};
		SongData.week_songs = playlist[0];
		SongData.week_diffs = songDiff;
		SongData.isPlaying = true;
		Global.changeScene("menus/editors/offset_editor/offset_menu", true, false);
		
		return;
		
	elif ev.keycode == GlobalOptions.get_key("camEditorKey"):
		SongData.week_songs = playlist[0];
		SongData.week_diffs = songDiff;
		SongData.isPlaying = true;
		Global.changeScene("menus/editors/cam_editor/cam_editor", true, false);
		
		return;
		
	if can_pause && (ev.keycode == GlobalOptions.get_key("enter") or ev.keycode == KEY_KP_ENTER):
		pause_menu.can_use = true;
		pause_menu.visible = true;
		
		pause_menu._paused();
		get_tree().paused = true;
		
		Discord.update_discord_info("pause", "Paused");
		
	if OS.is_debug_build():
		match ev.keycode:
			KEY_F1:
				finishSong();
				
func startCountdown():
	SongData.is_not_in_cutscene = true;
	MusicManager._stop_music();
	
	is_on_intro = true;
	start_song = true;
	
	var countdown_audios = ["intro3", "intro2", "intro1", "introGo"];
	var countdownPath = "default" if !SongData.isPixelStage else "pixel";
	var idleCounter = 0;
	
	if Conductor.startTime > 0:
		can_pause = true;
		is_on_intro = false;
		
		setTimePos(Conductor.startTime);
		
		Conductor.startTime = 0;
		Conductor.seekTime = 0;
		
		return;
		
	if skipIntro && is_on_intro:
		can_pause = true;
		is_on_intro = false;
		Conductor.getSongTime = 0.0;
		
		if SongData.needVoice:
			voices.play(0.0);
		inst.play(0.0);
		
		ScriptLoader.call_func("on_song_start");
		
		return;
		
	for i in [bf, dad, gf]:
		if is_instance_valid(i):
			i.back_to_idle(idleCounter);
			
	for i in 5:
		await get_tree().create_timer(Conductor.crochet/1000).timeout;
		
		ScriptLoader.call_func("on_countdown", [i]);
		
		if countdownSprite == null:
			continue;
			
		if i > 3:
			can_pause = true;
			is_on_intro = false;
			
			if SongData.needVoice:
				voices.play(0.0);
			inst.play(0.0);
			
			countdownSprite.queue_free();
			
			ScriptLoader.call_func("on_song_start");
			
			continue;
			
		Sound.playAudio(countdown_audios[i], SongData.isPixelStage);
		if GlobalOptions.updated_hud == "classic hud" && i == 0:
			continue;
			
		set_contdownSpr(countdownPath, countdownset[countdownPath][i] + ratingPart);
		
		idleCounter += 1;
		
func set_contdownSpr(path, spr):
	countdownSprite.texture = load("res://assets/images/coutdown/%s/%s.png"%[path, spr]);
	var tween = create_tween();
	tween.tween_property(countdownSprite, "modulate:a", 1.0, 0.15);
	tween.tween_property(countdownSprite, "modulate:a", 0.0, 0.15);
	
func startSong():
	if SongData.song == "":
		return;
		
	var music_inst = load("res://assets/songs/%s/song/Inst%s.ogg"%[SongData.song, "-remix" if songDiff == "remix" else ""]);
	var music_voices = "res://assets/songs/%s/song/Voices%s.ogg"%[SongData.song, "-remix" if songDiff == "remix" else ""];
	
	var music_voices_player = "res://assets/songs/%s/song/Voices-player%s.ogg"%[SongData.song, "-remix" if songDiff == "remix" else ""];
	var music_voices_opponent = "res://assets/songs/%s/song/Voices-opponent%s.ogg"%[SongData.song, "-remix" if songDiff == "remix" else ""];
	
	var vocalsSynchronized = AudioStreamSynchronized.new();
	if ResourceLoader.exists(music_voices_player) && ResourceLoader.exists(music_voices_opponent):
		vocalsSynchronized.stream_count = 2;
		vocalsSynchronized.set_sync_stream(0, load(music_voices_player));
		vocalsSynchronized.set_sync_stream(1, load(music_voices_opponent));
	else:
		vocalsSynchronized.stream_count = 1;
		vocalsSynchronized.set_sync_stream(0, load(music_voices));
		
	inst.stream = music_inst;
	voices.stream = vocalsSynchronized;
	
	var instLength = music_inst.get_length();
	var vocalsLength = vocalsSynchronized.get_sync_stream(0).get_length();
	
	songLength = max(instLength, vocalsLength);
	
	timeBar.max_value = songLength;
	
func finishSong():
	can_pause = false;
	
	ScriptLoader.call_func("on_song_end");
	
	SongData.isOnChartMode = false;
	SongData.restartSong = false;
	SongData.death_count = 0;
	
	var diffSet = "" if songDiff == "" else str('-', songDiff);
	
	if !GlobalOptions.isUsingBot or !SongData.isOnChartMode:
		if score > HighScore.get_score(playlist[0], diffSet):
			HighScore.get_song_score(playlist[0], diffSet, score);
			
		if setRank(HighScore.get_rank(playlist[0], diffSet), rankName):
			HighScore.get_song_rank(playlist[0], diffSet, rankName);
			
		if accuracyPercent > HighScore.get_percent(playlist[0], diffSet):
			HighScore.get_song_percent(playlist[0], diffSet, accuracyPercent);
	else:
		HighScore.get_song_score(playlist[0], diffSet, 0);
		HighScore.get_song_rank(playlist[0], diffSet, "???");
		HighScore.get_song_percent(playlist[0], diffSet, 0.0);
		
	inst.stop();
	voices.stop();
	
	if SongData.isStoryMode:
		playlist.remove_at(0);
		print(playlist);
		
		if playlist.is_empty():
			HighScore.week_status[SongData.weekName] = true;
			HighScore.save_week_status();
			
			await get_tree().create_timer(0.1).timeout
			
			MusicManager._play_song("freakyMenu", "music", true);
			Global.changeScene("menus/story_mode/storyMode", true, false);
			SongData.isPlaying = false;
			
		else:
			await get_tree().create_timer(0.1 if curSong != "eggnog" else 1.5).timeout
			
			Global.reloadScene();
			SongData.loadJson(playlist[0], songDiff);
	else:
		await get_tree().create_timer(0.1).timeout
		
		MusicManager._play_song("freakyMenu", "music", true);
		Global.changeScene("menus/freeplay/freeplay_menu", true, false);
		SongData.isPlaying = false;
		
	if SongData.isOnChartMode && curSong != "test" && curSong != "monster":
		Global.changeScene("menus/editors/chart_editor/chartState", true, false);
		
func splash_note(strum, anim):
	var splash = preload("res://source/arrows/splashes/noteSplashes.tscn").instantiate();
	splash.play_splash(strum.global_position.x, strum.global_position.y, anim);
	note_splshes.add_child(splash);
	return splash;
	
func updateScoreText():
	ratingName = setPercent();
	rankName = newRank();
	accuracyPercent = snapped(float(notesPlayed/totalHits)*100, 0.01) if totalHits > 0 else 0.0;
	
	if GlobalOptions.isUsingBot:
		scoreText.text = "BOTPLAY ON. SCORE WON'T BE SAVED";
		return;
		
	scoreText.text = ('Score: %s / Misses: %s / Rating: %s (%s) / Rank: %s'%[int(score), int(misses), ratingName, str(accuracyPercent, "%"), rankName]) if GlobalOptions.updated_hud == "new hud" else ('Score: %s'%[int(score)]);
	
	if GlobalOptions.show_ratingLabel:
		var base_text = "Total Hits: %s\nSicks: %s\nGoods: %s\nBads: %s\nShits: %s"%[int(totalHits), int(sicks), int(goods), int(bads), int(shits)];
		ratingText.text = base_text;
		if GlobalOptions.updated_hud == "classic hud":
			ratingText.text += "\nMisses: %s\nRank: %s"%[int(misses), rankName];
			
func setTimePos(time):
	time = max(0, time);
	
	if SongData.needVoice:
		voices.play(time/1000);
	inst.play(time/1000);
	
	Conductor.seekTime = time;
	Conductor.update_position(time);
	
	timeBar.value = Conductor.getSongTime/1000;
	
func setup_hud():
	for i in [healthBar, iconP1, iconP2]:
		i.modulate.a = 0.0 if GlobalOptions.hide_hud else GlobalOptions.health_bar_alpha;
		
	for i in [timeText, timeBar]:
		i.visible = GlobalOptions.timeBar_mode != "disable";
		
	if GlobalOptions.hide_hud:
		for i in [$hud/Hud_Layer/healthBar, $hud/Hud_Layer/icons, $hud/Hud_Layer/scoreLabel, $hud/Hud_Layer/timeLabel, $hud/Hud_Layer/timeBar]:
			i.hide();
			
	ratingText.visible = GlobalOptions.show_ratingLabel;
	msText.visible = GlobalOptions.showMsText;
	
func setup_hud_scroll():
	if GlobalOptions.middle_scroll:
		playerStrum.position.x = 478;
		opponentStrum.hide();
		
	if GlobalOptions.down_scroll:
		$hud/Hud_Layer/healthBar.position.y = 60;
		$hud/Hud_Layer/timeBar.position.y = 680;
		$hud/Hud_Layer/scoreLabel.position.y = 85;
		$hud/Hud_Layer/timeLabel.position.y = 675;
		
		for i in [playerStrum, opponentStrum]:
			i.position.y = 620;
		for i in [iconP1, iconP2]:
			i.position.y = 65;
			
func setup_classic_hud():
	if GlobalOptions.updated_hud != "classic hud":
		return;
		
	if !GlobalOptions.middle_scroll:
		playerStrum.position.x -= 80;
		
	scoreText.text = "Score: %s"%[int(score)];
	scoreText.position = Vector2(620, 90 if GlobalOptions.down_scroll else 680);
	scoreText.scale = Vector2.ONE * 0.03;
	
func step_hit(_step):
	if SongData.songSections[Conductor.curSection]["changeBPM"]:
		Conductor.changeBpm(SongData.songSections[Conductor.curSection]["bpm"]);
		
func beat_hit(_beat):
	pass;

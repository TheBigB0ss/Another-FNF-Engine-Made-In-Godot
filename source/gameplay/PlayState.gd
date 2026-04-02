extends Node

@onready var hud = $hud/Hud_Layer;
@onready var timeText = $'hud/Hud_Layer/timeLabel';
@onready var ratingText = $'hud/Hud_Layer/ratingLabel'
@onready var scoreText = $'hud/Hud_Layer/scoreLabel';
@onready var timeBar = $"hud/Hud_Layer/timeBar";

var health = 50.0;

@onready var healthBar = $'hud/Hud_Layer/healthBar';

@onready var voices = $'voices';
@onready var inst = $'inst';

var iconP1 = null;
var iconP2 = null
var iconP3 = null;
@onready var iconGrp = $'hud/Hud_Layer/icons';

var ratingPart = "";
var ratings = ["sick", "good", "bad", "shit", "miss"];

@onready var rating_spr = $'rating/Rating_Layer/rating';
@onready var combo_spr = $'rating/Rating_Layer/combo';
@onready var nums_spr = $'rating/Rating_Layer/nums';

@onready var pause_menu = $'pause/Pause_Layer';
@onready var dialogue_box = $'dialogue/DialogueBox';

@onready var note_splshes = $'strums/Strum_Layer/Splashes';

var can_pause = false;

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

@onready var playerStrum = $'strums/Strum_Layer/Player Notes';
@onready var opponentStrum = $'strums/Strum_Layer/Opponent Notes';
@onready var newOpponentStrum = $"strums/Strum_Layer/Second Opponent Note";
@onready var game_strums = $'strums/Strum_Layer';

var curStage = "";
var curSong = "";

var playlist = [];
var songDiff = [];
var isStoryMode = false;

var singAnims = [
	"singLeft", 
	"singDown", 
	"singUp", 
	"singRight"
];

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

var splash_normal:PackedScene;
var splash_pixel:PackedScene;

func load_json(path = "", key = ""):
	var jsonFile = FileAccess.open("res://"+path+".json", FileAccess.READ);
	var json = JSON.new();
	json.parse(jsonFile.get_as_text());
	jsonFile.close();
	
	var newData = json.get_data()[key];
	return newData;
	
func _ready():
	Conductor.reset();
	
	achievements_map = load_json("assets/data/gameplay_data", "achievements_map"); 
	rank_map = load_json("assets/data/gameplay_data", "rank_map"); 
	percentData = load_json("assets/data/gameplay_data", "percentData"); 
	countdownset = load_json("assets/data/gameplay_data", "countdownset"); 
	rating_data = load_json("assets/data/gameplay_data", "rating_data");
	
	get_tree().paused = false;
	pause_menu.visible = false;
	pause_menu.can_use = false;
	
	Conductor.connect("new_beat", beat_hit);
	Conductor.connect("new_step", step_hit);
	
	isStoryMode = SongData.isStoryMode;
	playlist = SongData.week_songs;
	songDiff = SongData.week_diffs;
	
	print("song week is: " + SongData.weekName);
	print("song list is: " + str(playlist));
	print("song diff is: " + str(songDiff));
	
	for i in [rating_spr, combo_spr, nums_spr]:
		if GlobalOptions.rating_mode == "hud element":
			i.reparent($rating/Rating_Layer, true);
		elif GlobalOptions.rating_mode == "game element":
			i.reparent($hud, true);
			
	splash_normal = preload("res://source/arrows/splashes/noteSplashes.tscn");
	splash_pixel = preload("res://source/arrows/splashes/pixel/pixelNoteSplash.tscn");
	
	SongData.isOnDeathScreen = false;
	SongData.isPlaying = true;
	
	ratingText.visible = GlobalOptions.show_ratingLabel;
	
	GlobalOptions.connect("ghost_tapping_miss", miss_note);
	Achievements.connect("end_achievement", finishSong);
	
	Global.connect("end_dialogue", startCoutdown);
	Global.connect("end_cutscene", startCoutdown);
	Global.connect("end_tankman_cutscene", startCoutdown);
	
	stage = load("res://source/stages/%s/%s.tscn"%[SongData.stage, SongData.stage]).instantiate();
	if stage is Stage:
		stage.init_game(self);
		
	SongData.loadStageJson(SongData.stage);
	
	curSong = SongData.song;
	curStage = SongData.stage;
	
	var bf_position = SongData.player1StagePosition;
	var gf_position = SongData.gfStagePosition;
	var opponent_position = SongData.gfStagePosition if SongData.player2 == "gf" else SongData.player2StagePosition;
	
	bf = add_character(bf_position, SongData.player1Zindex, SongData.player1, 4);
	dad = add_character(opponent_position, SongData.player2Zindex, SongData.player2, 3);
	gf = add_character(gf_position, SongData.gfZindex, SongData.gfPlayer, 1);
	if SongData.player3 != "" && SongData.haveTwoOpponents:
		new_opponent = add_character(SongData.player3StagePosition, SongData.player3Zindex, SongData.player3, 2);
		
	stageGrp.add_child(stage);
	
	bf.character.flip_h = !bf.is_player;
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
	
	iconP1 = add_icon(bf.curIcon, false, bf.animatedIcon, Vector2(710, 645));
	iconP2 = add_icon(dad.curIcon, true, dad.animatedIcon, Vector2(610, 645));
	if SongData.player3 != "" && SongData.haveTwoOpponents:
		iconP3 = add_icon(new_opponent.curIcon, true, new_opponent.animatedIcon, Vector2(550, 585));
		
	SongData.updated_chart = SongData.chartData;
	
	Conductor.mapBPMChanges(SongData.chartData);
	Conductor.changeBpm(SongData.songBpm);
	
	Conductor.getSongTime = -Conductor.crochet*5;
	Conductor.songSpeed = SongData.songSpeed;
	
	startSong();
	
	for i in [healthBar, iconP1, iconP2, iconP3]:
		if i != null:
			i.modulate.a = GlobalOptions.health_bar_alpha if !GlobalOptions.hide_hud else 0.0;
			
	for i in [timeBar, timeText]:
		i.modulate.a = GlobalOptions.time_bar_alpha;
		
	if GlobalOptions.hide_hud:
		for i in [$hud/Hud_Layer/healthBar, $hud/Hud_Layer/icons, $hud/Hud_Layer/scoreLabel, $hud/Hud_Layer/timeLabel, $hud/Hud_Layer/timeBar]:
			i.hide();
			
	if GlobalOptions.down_scroll:
		$hud/Hud_Layer/healthBar.position.y = 60;
		$hud/Hud_Layer/timeBar.position.y = 680;
		$hud/Hud_Layer/scoreLabel.position.y = 85;
		$hud/Hud_Layer/timeLabel.position.y = 675;
		
		for i in [playerStrum, opponentStrum]:
			i.position.y = 620;
			
		for i in [iconP1, iconP2]:
			i.position.y = 65;
			
		iconP3.position.y = 95;
		
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
	newOpponentStrum.appearNOW = skipIntro && SongData.haveTwoOpponents;
	
	if isStoryMode && SongData.death_count <= 0 && !SongData.restartSong && !curSong.contains("-remix"):
		match curSong:
			"ugh":
				stage.ugh_cutscene();
			"guns":
				stage.guns_intro();
			"stress":
				stage.stress_intro();
			"thorns":
				stage.start_cutscene();
				
	var txt_path = "res://assets/data/songs/%s/%sDialogue.txt"%[curSong, curSong];
	var json_path = "res://assets/data/songs/%s/%sDialogue.json"%[curSong, curSong];
	if FileAccess.file_exists(txt_path) or FileAccess.file_exists(json_path):
		if SongData.death_count <= 0 && isStoryMode && !SongData.restartSong:
			match curSong:
				"thorns":
					Global.connect("end_senpai_cutscene", start_dialogue);
				_:
					start_dialogue();
		else:
			startCoutdown();
	else:
		SongData.is_not_in_cutscene = true;
		
	if SongData.is_not_in_cutscene && !Global.is_on_video && !FileAccess.file_exists(txt_path):
		startCoutdown();
		
	sectionCamera.zoom = SongData.stageZoom;
	
	if SongData.is_not_in_cutscene && is_on_intro:
		move_cam(GlobalOptions.updated_cam == "smooth", (dad.global_position + Vector2(dad.camera_pos[0], dad.camera_pos[1])));
		
	if GlobalOptions.show_songCard:
		var newSongCard = SongCard.new();
		newSongCard.create_songBar(curSong);
		hud.add_child(newSongCard);
		hud.move_child(newSongCard, 8);
		
	if GlobalOptions.updated_hud == "classic hud":
		timeBar.hide();
		timeText.hide();
		if !GlobalOptions.middle_scroll:
			playerStrum.position.x -= 80;
			
		newOpponentStrum.position.x -= 35;
		scoreText.text = 'Score: %s'%[int(score)];
		scoreText.position = Vector2(620, 680);
		scoreText.scale = Vector2(0.03, 0.03);
		
	updateScoreText();
	
func add_character(position, z_index, path, child_id):
	if path == "none":
		return;
		
	var new_char = load("res://source/characters/" + path + ".tscn").instantiate();
	new_char.position = position;
	new_char.z_index = z_index;
	add_child(new_char);
	move_child(new_char, child_id);
	
	return new_char;
	
func add_icon(path, is_opponent, is_animated, icon_position):
	var new_icon = null;
	if is_animated:
		new_icon = AnimatedIcon.new();
		new_icon.icon_frames = "assets/images/icons/animated/%s/%s.res"%[path, path];
		new_icon.icon_char = path;
	else:
		new_icon = Icon.new();
		new_icon.reload_icon(path);
		
	new_icon.position = icon_position;
	new_icon.flip_h = !is_opponent;
	iconGrp.add_child(new_icon);
	
	return new_icon;
	
func start_dialogue():
	SongData.is_not_in_cutscene = false;
	dialogue_box.show();
	dialogue_box.pause_song();
	
var start_song = false;
var discord_songName = "";
var last_song_seek = 0.0;

func _process(delta: float) -> void:
	if !start_song:
		return;
		
	if !pause_menu.paused:
		inst.stream_paused = false;
		voices.stream_paused = false;
		
		Conductor.getSongTime += (delta*1000);
		
		if finished_song:
			return;
			
		if abs(inst.get_playback_position() - Conductor.getSongTime / 1000) > 0.03 && Time.get_ticks_msec() - last_song_seek > 500:
			inst.seek(Conductor.getSongTime / 1000);
			voices.seek(Conductor.getSongTime / 1000);
			last_song_seek = Time.get_ticks_msec();
	else:
		inst.stream_paused = true;
		voices.stream_paused = true;
		
	var helthLerpValue = lerp(float(healthBar.value), health, 0.40);
	healthBar.value = helthLerpValue;
	
	if SongData.is_not_in_cutscene && !Global.is_on_video:
		sectionCamera.zoom = lerp(sectionCamera.zoom, SongData.stageZoom, 0.09);
		
	if !is_on_intro && Conductor.getSongTime >= 0 && !playlist.is_empty():
		discord_songName = "Playing: %s (%s)"%[playlist[0], songDiff];
		
	if Conductor.getSongTime >= 0 && !is_on_intro:
		timeBar.value = Conductor.getSongTime/1000;
		
	timeBar.max_value = inst.stream.get_length();
	
	var healthRemap = remap(health, healthBar.min_value, healthBar.max_value, 850, 250);
	
	iconP1.position.x = lerp(iconP1.position.x, healthRemap+160, 0.40);
	iconP2.position.x = lerp(iconP2.position.x, healthRemap+55, 0.40);
	
	if iconP3 != null:
		iconP3.position.x = lerp(iconP3.position.x, healthRemap+20, 0.40);
		
	if GlobalOptions.isUsingBot:
		botplayText.show();
		botplayTime += delta;
		botplayText.modulate.a = ((1+sin(botplayTime*5))/2) if !SongData.isPixelStage else (round((1+sin(botplayTime*5))/2));
	else:
		botplayText.hide();
		
	for i in [dad, gf, bf, new_opponent]:
		if i == null: continue;
		cam_follow_poses(i);
		
	var curMinutes = str(int(inst.get_playback_position()) / 60).pad_zeros(1);
	var curSeconds = str(int(inst.get_playback_position()) % 60).pad_zeros(2);
	var maxMinutes = str(int(inst.stream.get_length()) / 60).pad_zeros(1);
	var maxSeconds = str(int(inst.stream.get_length()) % 60).pad_zeros(2);
	
	timeText.text = curMinutes + ":" + curSeconds + " / " + maxMinutes + ":" + maxSeconds if Conductor.getSongTime >= 0 else "0:00 / " + maxMinutes + ":" + maxSeconds
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
			set_new_achievement(SongData.weekName, true);
			
		if AchievementPopUp.achievements_fuck.is_empty():
			finishSong();
			
		finished_song = true;
		
	if health <= 0:
		playerDead();
		
	set_icon();
	newRank();
	
	Discord.update_discord_info("Playstate", str(discord_songName, " ",  timeText.text), "Another FNF Engine Made In Godot", Conductor.getSongTime/1000);
	
func set_new_achievement(achievement, final):
	AchievementPopUp.set_achievement(achievements_map[achievement][0], final);
	if songDiff == "hard":
		AchievementPopUp.set_achievement(achievements_map[achievement][1], final);
		
func set_icon():
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
		
	iconP1.play_icon_anim(iconP1_Anim);
	iconP2.play_icon_anim(iconP2_Anim);
	if iconP3 != null:
		iconP3.play_icon_anim(iconP3_Anim);
		
func pressedNote(note):
	if note.is_a_bad_note:
		return;
		
	voices.volume_db = 0;
	playerStrum.strumNode.get_child(note.noteData).strumPressed = true;
	
	var ms = (note.strumTime - Conductor.getSongTime);
	var pressed = false;
	
	if GlobalOptions.isUsingBot:
		return;
		
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
					var curSplash = int(randi_range(1, 2));
					var splashData = int(note.noteData)%4;
					var splashAnim = note.noteAnim;
					var splashPosX = playerStrum.position.x+playerStrum.strumNode.get_child(note.noteData).position.x;
					var splashPosY = playerStrum.position.y+playerStrum.strumNode.get_child(note.noteData).position.y;
					
					splash_note(curSplash, splashData, splashAnim, splashPosX, splashPosY);
					
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
		
		pressed = true;
		
func miss_note(_note):
	Sound.playAudio("miss_sounds/missnote%s"%[int(randi_range(1, 3))], false);
	Sound.audio.volume_db = -8;
	
	voices.volume_db = -80;
	misses += 1;
	health -= 4;
	notesPlayed = max(notesPlayed-0.8, 0.0);
	score -= 70;
	
	if combo > 10 && gf != null && SongData.gfPlayer != "none":
		gf._playAnim("sad");
		
	combo = 0;
	
	if curStage == "philly remix" && (curSong == "philly-nice-remix" && songDiff == "remix"):
		stage.funny_guy();
		
	if GlobalOptions.updated_hud != "classic hud":
		rating_spr.pop_up_rating(4);
		
	updateScoreText();
	
	await get_tree().create_timer(0.3).timeout;
	voices.volume_db = 0;
	
func playBfMissAnim(curNote):
	var coolAnims = singAnims[int(curNote.noteData)%4];
	
	if curNote.is_a_bad_note:
		if bf.animList.has("hit"):
			bf._playAnim("hit");
		#else:
		#	bf.modulate = Color(0x5425dfff);
		#	bf._playAnim(coolAnims);
	else:
		var miss_anim = coolAnims+" MISS";
		
		if bf.animList.has(miss_anim):
			bf._playAnim(miss_anim);
		#else:
		#	bf.modulate = Color(0x5425dfff)
		#	bf._playAnim(coolAnims);
			
func playCharacterAnim(curNote, new_char, isBf):
	if curNote.no_anim:
		return;
		
	var coolAnims = singAnims[int(curNote.noteData)%4];
	var altAnim = "-alt" if curNote.is_altAnim && dad.animList.has(coolAnims+"-alt") else "";
	
	if curNote.isGfNote && gf != null:
		gf._playAnim(coolAnims, curNote);
		return;
		
	if curNote.is_hey_note:
		new_char._playAnim("hey");
		return;
		
	if isBf && !new_char.is_player or bf.curCharacter == "tankman":
		coolAnims = swap_sing_anims(singAnims[int(curNote.noteData)%4], "singLeft", "singRight");
		
	if !isBf && new_char.is_player && dad.curCharacter != "tankman" && dad.curCharacter != "pico":
		coolAnims = swap_sing_anims(singAnims[int(curNote.noteData)%4], "singLeft", "singRight");
		
	if !curNote.isGfNote && !curNote.is_hey_note:
		new_char._playAnim(coolAnims+altAnim, curNote);
		
func swap_sing_anims(cur_anim, pos1, pos2):
	if cur_anim == pos1: return pos2;
	if cur_anim == pos2: return pos1;
	return cur_anim;
	
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
		strum_target.strumNode.get_child(note.noteData).reset_arrow_anim = timer;
		
	strum_target.strumNode.get_child(note.noteData).play_note_anim("confirm");
	
var cam_offset_values = {
	"singLeft": Vector2.LEFT,
	"singDown": Vector2.DOWN,
	"singUp": Vector2.UP,
	"singRight": Vector2.RIGHT
};
func cam_follow_poses(new_char):
	if !new_char.cam_follow_pos:
		return;
		
	var camOffset = cam_offset_values.get(new_char.curAnim, Vector2.ZERO)*20;
	sectionCamera.offset = lerp(sectionCamera.offset, camOffset, 0.07);
	
func playerDead():
	SongData.characters = {
		"bf": [bf.global_position, bf.scale, bf.rotation, bf.death_scene, bf.have_death_animation],
		"opponent": [dad.global_position, dad.scale, dad.rotation, dad.death_scene, dad.have_death_animation],
		"gf": [gf.global_position, gf.scale, gf.rotation, gf.death_scene, gf.have_death_animation] if gf != null else [Vector2(0,0), Vector2(0,0), 0.0, "", false]
	};
	SongData.camera_data = {
		"position": sectionCamera.global_position,
		"zoom": sectionCamera.zoom,
		"rotation": sectionCamera.rotation
	};
	SongData.death_count += 1;
	SongData.isOnDeathScreen = true;
	can_pause = false;
	Global.changeScene("/gameplay/death_scene/death_scene", false, false);
	
func newRank():
	if misses >= 10: return "Clear";
	elif misses > 0: return "SDCB";
	elif bads > 0 or shits > 0: return "FC";
	elif goods > 0: return "GFC";
	elif sicks > 0: return "SFC";
	else: return "???";
	
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
	if ev is InputEventKey:
		if ev.pressed && !ev.echo:
			if ev.keycode in [KEY_R]:
				playerDead();
				
			if ev.keycode in [Global.get_key("7")]:
				SongData.week_songs = playlist[0];
				SongData.isPlaying = false;
				Global.changeScene("menus/editors/chart_editor/chartState", true, false);
				
			if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && can_pause && !TennaJumpscare.itsTvTime:
				pause_menu.can_use = true;
				pause_menu.visible = true;
				
				pause_menu._paused();
				get_tree().paused = true;
				
				Discord.update_discord_info("pause", "Paused");
				
			if OS.is_debug_build():
				if ev.keycode in [KEY_F1]:
					set_new_achievement(SongData.weekName, false);
					finishSong();
					
func startCoutdown():
	SongData.is_not_in_cutscene = true;
	MusicManager._stop_music();
	is_on_intro = true;
	start_song = true;
	
	var countdownPath = "default" if !SongData.isPixelStage else "pixel";
	var idleCounter = 0;
	
	if skipIntro && is_on_intro:
		can_pause = true;
		is_on_intro = false;
		Conductor.getSongTime = 0.0;
		
		if SongData.needVoice:
			voices.play(0.0);
		inst.play(0.0);
		
		return;
		
	bf.beat_dance(idleCounter);
	dad.beat_dance(idleCounter);
	if is_instance_valid(gf):
		gf.beat_dance(idleCounter);
	if SongData.haveTwoOpponents && is_instance_valid(new_opponent):
		new_opponent.beat_dance(idleCounter);
		
	for i in 5:
		await get_tree().create_timer(Conductor.crochet/1000).timeout;
		
		if countdownSprite != null:
			match i:
				0:
					if GlobalOptions.updated_hud != "classic hud":
						set_contdownSpr(countdownPath, countdownset[countdownPath][0] + ratingPart);
					Sound.playAudio("intro3", SongData.isPixelStage);
				1:
					set_contdownSpr(countdownPath, countdownset[countdownPath][1] + ratingPart);
					Sound.playAudio("intro2", SongData.isPixelStage);
				2:
					set_contdownSpr(countdownPath, countdownset[countdownPath][2] + ratingPart);
					Sound.playAudio("intro1", SongData.isPixelStage);
				3:
					set_contdownSpr(countdownPath, countdownset[countdownPath][3] + ratingPart);
					Sound.playAudio("introGo", SongData.isPixelStage);
				4:
					countdownSprite.hide();
					can_pause = true;
					is_on_intro = false;
					
					if SongData.needVoice:
						voices.play(0.0);
					inst.play(0.0);
					
		idleCounter += 1;
		
func set_contdownSpr(path, spr):
	var tween = get_tree().create_tween();
	tween.tween_property(countdownSprite, "modulate:a", 1.0, 0.14);
	countdownSprite.texture = load("res://assets/images/coutdown/%s/%s.png"%[path, spr]);
	tween.tween_property(countdownSprite, "modulate:a", 0.0, 0.14);
	
func startSong():
	if SongData.song == "":
		return;
		
	var music_inst = load("res://assets/songs/" + SongData.song + "/Inst.ogg");
	var music_voices = load("res://assets/songs/" + SongData.song + "/Voices.ogg");
	
	inst.stream = music_inst;
	voices.stream = music_voices;
	
func finishSong():
	SongData.isOnChartMode = false;
	SongData.restartSong = false;
	SongData.death_count = 0;
	
	var diffSet = "" if songDiff == "" else str('-', songDiff);
	
	if !GlobalOptions.isUsingBot:
		if score > HighScore.get_score(playlist[0], diffSet):
			HighScore.get_song_score(playlist[0], diffSet, score);
			
		if setRank(HighScore.get_rank(playlist[0], diffSet), rankName):
			HighScore.get_song_rank(playlist[0], diffSet, rankName);
			
		if accuracyPercent > HighScore.get_percent(playlist[0], diffSet):
			HighScore.get_song_percent(playlist[0], diffSet, accuracyPercent);
			
	inst.stop();
	voices.stop();
	can_pause = false;
	
	match curSong:
		"test":
			HighScore.unlocksong("test", "bf-pixel", [0.0, 0.845, 1.0], "test week", ["easy", "normal", "hard"]);
		"monster":
			HighScore.unlocksong("monster", "monster", [1, 0.989, 0], "week 2", ["easy", "normal", "hard"]);
			
	if SongData.isStoryMode:
		if curSong == "eggnog" && !is_on_intro:
			Flash.just_appear(8, Color(0.0, 0.0, 0.0));
			Sound.playAudio("Lights_Shut_off", false);
			
		playlist.remove_at(0);
		print(playlist);
		
		if playlist.is_empty():
			HighScore.week_status[SongData.weekName] = true;
			HighScore.save_week_status();
			
			await get_tree().create_timer(0.1).timeout
			
			MusicManager._play_music("freakyMenu", true, true);
			Global.changeScene("menus/story_mode/storyMode", true, false);
			SongData.isPlaying = false;
			
		else:
			await get_tree().create_timer(0.1 if curSong != "eggnog" else 1.5).timeout
			
			Global.reloadScene();
			SongData.loadJson(playlist[0], songDiff);
	else:
		await get_tree().create_timer(0.1).timeout
		
		MusicManager._play_music("freakyMenu", true, true);
		Global.changeScene("menus/freeplay/freeplay_menu", true, false);
		SongData.isPlaying = false;
		
	if SongData.isOnChartMode && curSong != "test" && !curSong == "south-old" && curSong != "monster":
		Global.changeScene("menus/editors/chart_editor/chartState", true, false);
		
func splash_note(data, noteData, dir, splash_x, splash_y):
	var splash = splash_pixel.instantiate() if SongData.isPixelStage else splash_normal.instantiate();
	splash.cool_splash(data, noteData, dir, splash_x, splash_y);
	note_splshes.add_child(splash);
	
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
		if GlobalOptions.updated_hud == "classic hud":
			ratingText.text = base_text + "\nMisses: %s\nRank: %s"%[int(misses), rankName];
		else:
			ratingText.text = base_text;
			
var cam_target = null;
func step_hit(_step):
	if Conductor.curSection >= SongData.songNotes.size():
		return;
		
	if SongData.chartData["song"]["notes"][Conductor.curSection]["changeBPM"]:
		Conductor.changeBpm(SongData.chartData["song"]["notes"][Conductor.curSection]["bpm"]);
		
	camera_on_Bf = SongData.chartData["song"]["notes"][Conductor.curSection]["mustHitSection"];
	gf_is_singing = SongData.chartData["song"]["notes"][Conductor.curSection]["gfSection"];
	
	if camera_focus:
		return;
		
	cam_target = dad;
	if gf_is_singing:
		cam_target = gf;
	elif camera_on_Bf:
		cam_target = bf;
		
	if sectionCamera != null && SongData.isPlaying && cam_target != null:
		move_cam(GlobalOptions.updated_cam == "smooth", (cam_target.global_position + Vector2(cam_target.camera_pos[0], cam_target.camera_pos[1])));
		
func beat_hit(beat):
	if !GlobalOptions.screen_zoom:
		return;
		
	if beat % 4 == 0 && !is_on_intro:
		sectionCamera.zoom = SongData.stageZoomBeat;
		
func move_cam(smoothing, pos):
	sectionCamera.global_position = (pos if !smoothing else lerp(sectionCamera.global_position, pos, 0.55));

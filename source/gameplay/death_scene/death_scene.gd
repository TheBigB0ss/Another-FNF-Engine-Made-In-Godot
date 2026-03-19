extends Node2D

@onready var death_pos = $'death_position';

@onready var bf = load("res://source/characters/" + SongData.player1 + ".tscn").instantiate();
var death_anim = null;
var song = "";

func _ready():
	song = SongData.week_songs[0];
	
	if bf.death_scene == null or !bf.have_death_animation:
		death_anim = load("res://source/characters/Bf dead.tscn").instantiate();
	else:
		death_anim = load(bf.death_scene).instantiate();
	death_pos.add_child(death_anim);
	
	death_anim._playAnim("dead");
	
	if SongData.isOnDeathScreen:
		if song == "ugh" or song == "guns" or song == "stress":
			Sound.add_new_sound("game over/tankman gameover voice lines/jeffGameover-%s"%[choice_voice_line()], PROCESS_MODE_INHERIT, 0.0);
			
		Sound.playAudio("game over/fnf_loss_sfx", false);
		if death_anim.charPath == "Bf Pixel dead":
			Sound.playAudio("game over/fnf_loss_sfx", true);
			
func choice_voice_line():
	return int(randi_range(1, 25));
	
var dead_confirmed = false;
func _process(delta: float) -> void:
	if confirm:
		if death_anim.curAnim == "dead confirm" && death_anim.confirmTimer >= 2.5 && death_anim.confirmTimer < 2.6:
			death_anim.idleTimer = 0;
			SongData.loadJson(SongData.week_songs[0], SongData.week_diffs);
			Global.changeScene("gameplay/PlayState", true, false);
			
	else:
		if !dead_confirmed && death_anim.curAnim == "dead loop":
			if death_anim.charPath == "Bf Pixel dead":
				MusicManager._play_music("game over/gameOver-pixel", false, true);
				
			MusicManager._play_music("game over/gameOver", false, true);
			
			dead_confirmed = true;
			
var confirm = false;
func _input(ev):
	if ev is InputEventKey && SongData.isOnDeathScreen:
		if ev.pressed && !ev.echo && !confirm:
			if ev.keycode in [KEY_ENTER] && death_anim.curAnim != "dead":
				MusicManager._play_music("game over/gameOverEnd", false, false);
				if death_anim.charPath == "Bf Pixel dead":
					MusicManager._play_music("game over/gameOverEnd-pixel", false, true);
					
				death_anim._playAnim("dead confirm");
				death_anim.idleTimer = 0;
				confirm = true;
				SongData.isOnDeathScreen = false;
				
			if ev.keycode in [KEY_ESCAPE]:
				SongData.death_count = 0;
				MusicManager._stop_music();
				MusicManager._play_music("freakyMenu", true, true);
				Global.changeScene("menus/story_mode/storyMode" if SongData.isStoryMode else "menus/freeplay/freeplay_menu");
				confirm = true;
				SongData.isOnDeathScreen = false;

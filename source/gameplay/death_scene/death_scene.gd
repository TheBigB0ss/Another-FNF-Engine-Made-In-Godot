extends Node2D

@onready var camera = $Camera2D;

var death_anim = null;
var song = "";

func _ready():
	Conductor.reset();
	
	song = SongData.week_songs[0];
	
	death_anim = load("res://source/characters/characters_scenes/Bf dead.tscn" if SongData.characters["bf"][3] == null or !SongData.characters["bf"][4] else SongData.characters["bf"][3]).instantiate();
	death_anim.global_position = SongData.characters["bf"][0];
	death_anim.scale = SongData.characters["bf"][1];
	death_anim.rotation = SongData.characters["bf"][2];
	add_child(death_anim);
	
	death_anim._playAnim("dead");
	
	Global.emit_signal("on_death_screen");
	
	camera.global_position = SongData.camera_data["position"];
	camera.zoom = SongData.camera_data["zoom"];
	camera.rotation = SongData.camera_data["rotation"];
	
	if SongData.isOnDeathScreen:
		if song == "ugh" or song == "guns" or song == "stress":
			Sound.add_new_sound("game over/tankman gameover voice lines/jeffGameover-%s"%[randi_range(1, 25)]);
			
		Sound.playAudio("game over/fnf_loss_sfx", false);
		if death_anim.curCharacter == "Bf Pixel dead":
			Sound.playAudio("game over/fnf_loss_sfx", true);
			
var dead_confirmed = false;
var confirm = false;
func _process(_delta: float) -> void:
	if confirm:
		if death_anim.curAnim == "dead confirm" && death_anim.confirmTimer >= 2.5 && death_anim.confirmTimer < 2.6:
			death_anim.idleTimer = 0;
			SongData.loadJson(SongData.week_songs[0], SongData.week_diffs);
			Global.changeScene("gameplay/PlayState", true, false);
	else:
		if !dead_confirmed && death_anim.curAnim == "dead loop":
			var tw = get_tree().create_tween();
			tw.tween_property(camera, "global_position", death_anim.global_position, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT);
			tw.tween_property(camera, "zoom", Vector2.ONE, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT);
			
			Global.emit_signal("on_death_confirm");
			
			if death_anim.curCharacter == "Bf Pixel dead":
				MusicManager._play_song("game over/gameOver-pixel", "music", true);
			else:
				MusicManager._play_song("game over/gameOver", "music", true);
				
			dead_confirmed = true;
			
func _input(ev):
	if ev is InputEventKey && SongData.isOnDeathScreen:
		if ev.pressed && !ev.echo && !confirm:
			if ev.keycode in [KEY_ENTER] && death_anim.curAnim != "dead":
				MusicManager._play_song("game over/gameOverEnd", "music", false);
				if death_anim.curCharacter == "Bf Pixel dead":
					MusicManager._play_song("game over/gameOverEnd-pixel", "music", false);
					
				death_anim._playAnim("dead confirm");
				death_anim.idleTimer = 0;
				
				SongData.isOnDeathScreen = false;
				
				confirm = true;
				
				var tw = get_tree().create_tween();
				tw.tween_property(camera, "zoom", SongData.camera_data["zoom"], 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT);
				
			if ev.keycode in [KEY_ESCAPE]:
				SongData.death_count = 0;
				MusicManager._stop_music();
				MusicManager._play_song("freakyMenu", "music", true);
				Global.changeScene("menus/story_mode/storyMode" if SongData.isStoryMode else "menus/freeplay/freeplay_menu");
				confirm = true;
				SongData.isOnDeathScreen = false;
				

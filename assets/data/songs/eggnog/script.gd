extends FunkinScript

func on_song_end():
	if SongData.isStoryMode:
		if !game.is_on_intro:
			Flash.just_appear(8, Color(0.0, 0.0, 0.0));
			Sound.playAudio("Lights_Shut_off", false);
			

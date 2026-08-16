extends FunkinScript

func on_song_end():
	if game.dad.curCharacter == "senpai" && game.bf.curCharacter == "senpai" && game.gf.curCharacter == "senpai":
		SongData.isOnChartMode = false;
		AchievementPopUp.set_achievement('senpai senpai senpai senpai', true);
		

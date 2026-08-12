extends FunkinScript

func on_song_end():
	HighScore.unlocksong("monster", "monster", [1, 0.989, 0], "week 2", ["easy", "normal", "hard"]);

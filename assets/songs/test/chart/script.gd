extends FunkinScript

func on_song_start():
	HighScore.unlocksong("test", "bf-pixel", [0.0, 0.845, 1.0], "test week", ["easy", "normal", "hard"]);

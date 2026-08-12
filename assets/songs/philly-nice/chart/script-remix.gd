extends FunkinScript

func on_note_miss(_note:Note):
	if game.curSong == "philly-nice" && game.curStage == "philly_remix" && game.songDiff == "remix":
		game.stage.funny_guy();
		

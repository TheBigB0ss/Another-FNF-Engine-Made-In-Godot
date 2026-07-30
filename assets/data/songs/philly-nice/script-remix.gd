extends FunkinScript

func on_note_miss(_note:Note):
	if game.curSong == "philly-nice-remix" && game.curStage == "philly_remix":
		game.stage.funny_guy();
		

extends FunkinScript

func on_note_miss(_note:Note):
	if game.curSong == "blammed-remix" && game.curStage == "philly_remix":
		game.stage.funny_guy();
		

extends FunkinScript

func on_note_hit(_note:Note):
	if get_game_var("combo") > 0 && get_game_var("combo") % 10 == 0 && game.dad.curCharacter == "gf":
		game.dad._playAnim("hey", true);
		

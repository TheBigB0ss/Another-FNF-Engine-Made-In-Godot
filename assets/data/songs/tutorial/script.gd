extends FunkinScript

func on_note_hit(_note:Note):
	if get_game_var("combo") > 0 && get_game_var("combo") % 10 == 0 && game.dad.curCharacter == "gf":
		game.dad._playAnim("hey", true);
		
func on_process(_delta):
	if Conductor.curSection >= SongData.songSections.size():
		return;
		
	if !SongData.songSections[Conductor.curSection]["mustHitSection"]:
		call_game_func("cam_follow_poses", [game.dad]);
		

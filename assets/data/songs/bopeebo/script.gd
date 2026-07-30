extends FunkinScript

func on_ready():
	if game.curSong == "bopeebo-remix":
		game.sectionCamera.useDefaultCamsEvent = true;
		game.sectionCamera.useDefaultZoomEvent = true;
		

extends Stage

func _ready():
	if GlobalOptions.use_shader:
		$CanvasLayer.show();
	else:
		$CanvasLayer.hide();
		
	$bgFreaks.play("BG girls group" if game.curSong != "roses" else "BG fangirls dissuaded");

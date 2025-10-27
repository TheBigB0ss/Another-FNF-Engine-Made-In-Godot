extends Node2D

var song = "";

func _ready() -> void:
	if Global.is_playing:
		song = Global.songsShit[0].to_lower() if Global.isStoryMode else Global.songsShit.to_lower();
		
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
func soakedAppears():
	return randi_range(0, 1000);

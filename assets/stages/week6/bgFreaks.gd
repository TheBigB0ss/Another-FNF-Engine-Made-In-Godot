extends Node2D

func _ready() -> void:
	if SongData.isPlaying:
		if SongData.week_songs[0] == "roses":
			$Character_Animation.play("BG fangirls dissuaded/ ");
		else:
			$Character_Animation.play("BG girls group/ ");

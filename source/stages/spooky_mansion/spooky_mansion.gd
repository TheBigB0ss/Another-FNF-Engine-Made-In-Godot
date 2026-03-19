extends Stage

@onready var lightningBgAnim = $'spooky Bg';

func _ready():
	lightningBgAnim.play("halloweem bg");
	
func lightning():
	lightningBgAnim.play("halloweem bg lightning strike");
	Flash.flashAppears(0.3);
	Sound.playAudio("thunder_%s"%[int(randi_range(1, 2))], false);
	
func _on_spooky_bg_animation_finished() -> void:
	lightningBgAnim.play("halloweem bg");
	
func beat_hit(beat) -> void:
	if beat % 2 == 0:
		if int(randf_range(0, 65)) <= 4 && !game.is_on_intro:
			lightning();
			if game.bf.animList.has("idle shaking"):
				game.bf._playAnim("idle shaking");
				
			if game.gf.animList.has("scared") && SongData.gfPlayer != "none" && game.gf != null:
				game.gf._playAnim("scared");
				

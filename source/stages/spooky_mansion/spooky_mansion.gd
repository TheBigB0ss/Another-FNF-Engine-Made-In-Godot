extends Stage

@onready var lightningBgAnim = $'bg';

var lightningStrikeBeat = 0;
var lightningStrikeOffset = 8;

func _ready():
	resetLightning();
	
	lightningBgAnim.play("halloweem bg");
	lightningBgAnim.animation_finished.connect(_on_spooky_bg_animation_finished);
	
func beat_hit(beat):
	if beat == 4 && game.curSong == "spookeez":
		lightning(false, beat);
		
	if randf() < 0.1 && beat > lightningStrikeBeat + lightningStrikeOffset:
		lightning(true, beat);
		
func lightning(playSound = true, beat = 0):
	if playSound:
		Sound.add_new_sound("thunder_%s"%[randi_range(1, 2)]);
		
	lightningBgAnim.play("halloweem bg lightning strike");
	
	lightningStrikeBeat = beat;
	lightningStrikeOffset = randi_range(8, 24);
	
	Flash.flashAppears(0.3);
	
	if game.bf != null:
		if game.bf.animList.has("scared") && game.bf.animation.name != "cheer":
			game.bf._playAnim("scared");
			
	if game.gf != null:
		if game.gf.animList.has("scared"):
			game.gf._playAnim("scared");
			
func _on_spooky_bg_animation_finished() -> void:
	lightningBgAnim.play("halloweem bg");
	
func resetLightning():
	lightningStrikeBeat = 0;
	lightningStrikeOffset = 8;
	

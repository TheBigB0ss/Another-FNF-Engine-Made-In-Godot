extends Node2D

@onready var lightningBgAnim = $'spooky Bg';
var isAThunder = false;

func _ready():
	Global.connect("new_beat", beat_hit);
	
	lightningBgAnim.play("halloweem bg");
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
func lightning():
	lightningBgAnim.play("halloweem bg lightning strike");
	Flash.flashAppears(0.3);
	SoundStuff.playAudio("thunder_%s"%[int(randi_range(1, 2))], false);
	
func soakedAppears():
	return randi_range(0, 1000);
	
func _on_spooky_bg_animation_finished() -> void:
	lightningBgAnim.play("halloweem bg");
	
func beat_hit(beat):
	if int(randf_range(0, 65)) <= 4 && !get_tree().current_scene.get("is_on_intro"):
		lightning();
		if get_tree().current_scene.get("bf").animList.has("idle shaking"):
			get_tree().current_scene.get("bf")._playAnim("idle shaking");
			
		if get_tree().current_scene.get("gf").animList.has("scared") && SongData.gfPlayer != "none" && get_tree().current_scene.get("gf") != null:
			get_tree().current_scene.get("gf")._playAnim("scared");
			

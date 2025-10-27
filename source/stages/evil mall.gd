extends Node2D

func _ready():
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
func soakedAppears():
	return randi_range(0, 1000);
	
func winterHorrorland_cutscene():
	set_hud(false)
	Global.is_not_in_cutscene = false;
	Global.is_on_video = true;
	
	var camera = get_tree().current_scene.get("sectionCamera");
	camera.position = Vector2(540, -240);
	camera.zoom = Vector2(1.65, 1.65);
	
	Flash.just_appear(0.5, Color(0.0, 0.0, 0.0));
	
	await get_tree().create_timer(0.5).timeout
	SoundStuff.playAudio("Lights_Turn_On", false);
	
	await get_tree().create_timer(1.8).timeout
	camera.zoom = lerp(camera.zoom, Vector2(0.8, 0.8), 0.9);
	camera.position = Vector2(565, 610);
	
	await get_tree().create_timer(0.8).timeout
	start_song();
	
func set_hud(is_visible):
	var strums = get_tree().current_scene.get("cool_strums");
	var hud = get_tree().current_scene.get("cool_hud");
	strums.visible = is_visible;
	hud.visible = is_visible;
	
func start_song():
	set_hud(true);
	MusicManager._stop_music();
	Global.is_not_in_cutscene = true;
	Global.is_on_video = false;
	Global.emit_signal("eng_tankman_cutscene");

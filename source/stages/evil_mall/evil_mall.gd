extends Stage

#you know what, fuck this cutscene
func winterHorrorland_cutscene():
	set_hud(false);
	SongData.is_not_in_cutscene = false;
	Global.is_on_video = true;
	
	var camera = get_tree().current_scene.get("sectionCamera");
	camera.position = %tree_pos.position;
	camera.zoom = Vector2(1.395, 1.395);
	
	Flash.just_appear(0.5, Color(0.0, 0.0, 0.0));
	
	await get_tree().create_timer(0.5).timeout
	Sound.playAudio("Lights_Turn_On", false);
	
	await get_tree().create_timer(1.8).timeout
	camera.zoom = lerp(camera.zoom, Vector2(0.8, 0.8), 0.9);
	camera.position = Vector2(565, 610);
	
	await get_tree().create_timer(0.8).timeout
	start_song();
	
func set_hud(_is_visible):
	var strums = get_tree().current_scene.get("game_strums")
	var hud = get_tree().current_scene.get("hud");
	strums.visible = _is_visible;
	hud.visible = _is_visible;
	
func start_song():
	set_hud(true);
	MusicManager._stop_music();
	SongData.is_not_in_cutscene = true;
	Global.is_on_video = false;
	Global.emit_signal("end_cutscene");
	
